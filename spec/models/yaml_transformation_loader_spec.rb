# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YamlTransformationLoader, type: :model do
  let(:loader) { described_class.new }
  let(:sample_yaml_content) do
    <<~YAML
      name: "test_transformation"
      description: "A test transformation for specs"
      version: "1.0"
      
      transformations:
        - type: "regex_replace"
          config:
            pattern: "hello"
            replacement: "hi"
    YAML
  end

  describe '#load_from_string' do
    context 'with valid YAML' do
      it 'creates a transformation from YAML content' do
        transformation = loader.load_from_string(sample_yaml_content)

        expect(transformation).to be_a_valid_transformation
        expect(transformation.name).to eq("test_transformation")
        expect(transformation.description).to eq("A test transformation for specs")
      end

      it 'applies the transformation correctly' do
        transformation = loader.load_from_string(sample_yaml_content)
        result = transformation.apply("hello world")

        expect(result).to eq("hi world")
      end
    end

    context 'with invalid YAML syntax' do
      let(:invalid_yaml) do
        <<~YAML
          name: "bad_yaml
          description: missing quote above
        YAML
      end

      it 'raises a meaningful error' do
        expect {
          loader.load_from_string(invalid_yaml)
        }.to raise_error(YamlTransformationLoader::InvalidYamlError, /YAML syntax error/)
      end
    end

    context 'with missing required fields' do
      let(:incomplete_yaml) do
        <<~YAML
          name: "incomplete"
          # Missing description, version, transformations
        YAML
      end

      it 'raises a validation error' do
        expect {
          loader.load_from_string(incomplete_yaml)
        }.to raise_error(YamlTransformationLoader::ValidationError, /Missing required fields/)
      end
    end

    context 'with invalid transformation type' do
      let(:invalid_type_yaml) do
        <<~YAML
          name: "invalid_type"
          description: "Has unknown transformation type"
          version: "1.0"
          
          transformations:
            - type: "unknown_transformer"
              config: {}
        YAML
      end

      it 'raises an error for unknown transformation type' do
        expect {
          loader.load_from_string(invalid_type_yaml)
        }.to raise_error(YamlTransformationLoader::UnknownTransformationTypeError)
      end
    end
  end

  describe '#load_from_file' do
    let(:temp_file) { Tempfile.new(['test_transform', '.yml']) }

    before do
      temp_file.write(sample_yaml_content)
      temp_file.close
    end

    after do
      temp_file.unlink
    end

    it 'loads transformation from file' do
      transformation = loader.load_from_file(temp_file.path)

      expect(transformation.name).to eq("test_transformation")
      expect(transformation.apply("hello world")).to eq("hi world")
    end

    it 'raises error for non-existent file' do
      expect {
        loader.load_from_file("/non/existent/file.yml")
      }.to raise_error(YamlTransformationLoader::FileNotFoundError)
    end
  end

  describe 'multi-step transformations' do
    let(:multi_step_yaml) do
      <<~YAML.strip
        name: "log_enhancer"
        description: "Enhance log readability with multiple steps"
        version: "1.0"
        
        transformations:
          - type: "regex_replace"
            config:
              pattern: '(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2})'
              replacement: '\\1 \\2'
          
          - type: "regex_replace"
            config:
              pattern: '\\b(ERROR|FATAL)\\b'
              replacement: '[[\\1]]'
      YAML
    end

    it 'applies transformations sequentially' do
      transformation = loader.load_from_string(multi_step_yaml)
      input = "2025-07-02T14:30:45 ERROR: Something went wrong"
      result = transformation.apply(input)

      expect(result).to eq("2025-07-02 14:30:45 [[ERROR]]: Something went wrong")
    end
  end
end

RSpec.describe YamlTransformations::FunctionBasedTransformation, type: :model do
  let(:function_registry) { YamlFunctionRegistry.new }

  describe 'function-based transformations' do
    let(:function_yaml) do
      <<~YAML
        name: "k8s_secret_decoder"
        description: "Decode base64 secrets from Kubernetes YAML"
        version: "1.0"
        
        transformations:
          - type: "function_based"
            config:
              template: |
                {{ input 
                   | split_lines 
                   | map_values(base64_decode) 
                   | join_lines }}
              
              allowed_functions:
                - split_lines
                - map_values
                - base64_decode
                - join_lines
      YAML
    end

    let(:k8s_secret_input) do
      <<~YAML
        apiVersion: v1
        kind: Secret
        data:
          username: YWRtaW4=
          password: MWYyZDFlMmU2N2Rm
      YAML
    end

    before do
      # Mock the function registry with test implementations
      allow(function_registry).to receive(:call_function) do |name, input|
        case name
        when 'split_lines'
          input.split("\n")
        when 'map_values'
          # Simplified implementation for testing
          input.map { |line|
            if line.match?(/^\s*([^:]+):\s*([^\s]+)\s*$/)
              line.gsub(/([^:]+):\s*([^\s]+)/) { |match|
                "#{$1}: #{Base64.decode64($2)}"
              }
            else
              line
            end
          }
        when 'base64_decode'
          Base64.decode64(input)
        when 'join_lines'
          input.join("\n")
        else
          raise "Unknown function: #{name}"
        end
      end
    end

    it 'executes whitelisted functions correctly' do
      loader = YamlTransformationLoader.new(function_registry)
      transformation = loader.load_from_string(function_yaml)

      expect(transformation).to be_a_valid_transformation
      expect(transformation.name).to eq("k8s_secret_decoder")
    end

    it 'prevents execution of non-whitelisted functions' do
      malicious_yaml = function_yaml.gsub('base64_decode', 'system')

      loader = YamlTransformationLoader.new(function_registry)
      transformation = loader.load_from_string(malicious_yaml)

      # Security validation should catch unauthorized functions during validation
      validation_result = transformation.validate_input("test")
      expect(validation_result).not_to be_valid
      expect(validation_result.errors.join).to include('not whitelisted')
    end
  end
end

RSpec.describe YamlFunctionRegistry, type: :model do
  let(:registry) { described_class.new }

  describe '#call_function' do
    it 'executes whitelisted functions' do
      result = registry.call_function('base64_encode', 'hello')
      expect(result).to eq(Base64.encode64('hello').strip)
    end

    it 'prevents execution of dangerous functions' do
      expect {
        registry.call_function('system', 'rm -rf /')
      }.to raise_error(YamlFunctionRegistry::UnauthorizedFunctionError)
    end

    it 'provides meaningful error for unknown functions' do
      expect {
        registry.call_function('unknown_function', 'input')
      }.to raise_error(YamlFunctionRegistry::UnauthorizedFunctionError, /unknown_function/)
    end
  end

  describe '#whitelisted_functions' do
    it 'returns list of allowed functions' do
      functions = registry.whitelisted_functions

      expect(functions).to include('base64_encode')
      expect(functions).to include('base64_decode')
      expect(functions).to include('split_lines')
      expect(functions).not_to include('system')
      expect(functions).not_to include('eval')
    end
  end
end
