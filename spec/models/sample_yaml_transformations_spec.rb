# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sample YAML Transformations', type: :model do
  let(:loader) { YamlTransformationLoader.new }
  let(:transformations_dir) { Rails.root.join('config', 'transformations') }

  describe 'K8s Secret Decoder' do
    let(:k8s_secret_path) { transformations_dir.join('k8s_secret_decoder.yml') }

    it 'loads the transformation from file' do
      transformation = loader.load_from_file(k8s_secret_path)

      expect(transformation).to be_a_valid_transformation
      expect(transformation.name).to eq('k8s_secret_decoder')
      expect(transformation.description).to include('base64 secrets')
    end

    it 'processes K8s Secret format with function-based transformation' do
      transformation = loader.load_from_file(k8s_secret_path)

      input = <<~YAML.strip
        apiVersion: v1
        kind: Secret
        data:
          username: YWRtaW4=
          password: MWYyZDFlMmU2N2Rm
      YAML

      result = transformation.apply(input)

      # Function-based transformation should process the input
      expect(result).to include('apiVersion: v1')
      expect(result).to include('kind: Secret')
    end
  end

  describe 'Log Timestamp Normalizer' do
    let(:timestamp_normalizer_path) { transformations_dir.join('log_timestamp_normalizer.yml') }

    it 'loads the transformation from file' do
      transformation = loader.load_from_file(timestamp_normalizer_path)

      expect(transformation).to be_a_valid_transformation
      expect(transformation.name).to eq('log_timestamp_normalizer')
    end

    it 'converts ISO timestamps to readable format' do
      transformation = loader.load_from_file(timestamp_normalizer_path)

      input = "2025-07-02T14:30:45.123Z INFO: Application started"
      result = transformation.apply(input)

      expect(result).to eq("2025-07-02 14:30:45 INFO: Application started")
    end

    it 'handles multiple timestamps in log entries' do
      transformation = loader.load_from_file(timestamp_normalizer_path)

      input = <<~LOG.strip
        2025-07-02T14:30:45Z INFO: Server started
        2025-07-02T14:31:00.456Z ERROR: Connection failed
        2025-07-02T14:31:15Z DEBUG: Retrying connection
      LOG

      result = transformation.apply(input)

      expect(result).to include("2025-07-02 14:30:45 INFO")
      expect(result).to include("2025-07-02 14:31:00 ERROR")
      expect(result).to include("2025-07-02 14:31:15 DEBUG")
    end
  end

  describe 'Log Level Highlighter' do
    let(:log_highlighter_path) { transformations_dir.join('log_level_highlighter.yml') }

    it 'loads the multi-step transformation from file' do
      transformation = loader.load_from_file(log_highlighter_path)

      expect(transformation).to be_a_valid_transformation
      expect(transformation.name).to eq('log_level_highlighter')
      expect(transformation).to be_a(YamlTransformations::CompositeTransformation)
    end

    it 'adds emoji highlights to different log levels' do
      transformation = loader.load_from_file(log_highlighter_path)

      input = <<~LOG.strip
        INFO: Application started successfully
        ERROR: Database connection failed
        WARN: High memory usage detected
        DEBUG: Processing user request
        FATAL: System crash detected
      LOG

      result = transformation.apply(input)

      expect(result).to include('🔵 [INFO]')
      expect(result).to include('🔴 [ERROR]')
      expect(result).to include('🟡 [WARN]')
      expect(result).to include('⚪ [DEBUG]')
      expect(result).to include('🔴 [FATAL]')
    end

    it 'handles case-insensitive log levels' do
      transformation = loader.load_from_file(log_highlighter_path)

      input = "error: Something went wrong"
      result = transformation.apply(input)

      expect(result).to include('🔴 [error]')
    end
  end

  describe 'Loading all sample transformations' do
    it 'loads all transformations from the directory' do
      transformations = loader.load_from_directory(transformations_dir)

      expect(transformations.length).to be >= 3

      transformation_names = transformations.map(&:name)
      expect(transformation_names).to include('k8s_secret_decoder')
      expect(transformation_names).to include('log_timestamp_normalizer')
      expect(transformation_names).to include('log_level_highlighter')
    end

    it 'ensures all transformations are valid' do
      transformations = loader.load_from_directory(transformations_dir)

      transformations.each do |transformation|
        expect(transformation).to be_a_valid_transformation
        expect(transformation.name).to be_present
        expect(transformation.description).to be_present
      end
    end
  end
end
