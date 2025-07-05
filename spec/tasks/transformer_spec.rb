# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'transformer rake tasks', type: :task do
  # Re-enable the task before each run so it can be invoked multiple times
  before(:each) do
    Rake::Task['transformer:list'].reenable
    Rake::Task['transformer:validate'].reenable
  end

  describe 'transformer:list' do
    it 'prints a list of available transformations' do
      # Mock Dir.glob to return a predictable list of files
      allow(Dir).to receive(:glob).with(Rails.root.join('config', 'transformations', '*.yml')).and_return([
        Rails.root.join('config', 'transformations', 'first_transform.yml').to_s,
        Rails.root.join('config', 'transformations', 'second_transform.yml').to_s
      ])

      # Capture stdout and run the task
      expect { Rake::Task['transformer:list'].invoke }.to output(
        /Available Transformations:.*first_transform.*second_transform/m
      ).to_stdout
    end
  end

  describe 'transformer:validate' do
    let(:schema_path) { Rails.root.join('docs', 'schemas', 'transformation_schema.json') }
    let(:schema) { File.read(schema_path) }

    before do
      # Stub the read for the transformation schema
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(schema_path.to_s).and_return(schema)
    end

    context 'with valid transformation files' do
      it 'prints a success message' do
        valid_yaml = {
          'name' => 'valid_transform',
          'description' => 'A valid transformation',
          'version' => '1.0',
          'transformations' => [
            {
              'type' => 'regex_replace',
              'config' => { 'pattern' => 'a', 'replacement' => 'b' }
            }
          ]
        }.to_yaml

        allow(Dir).to receive(:glob).with(Rails.root.join('config', 'transformations', '*.yml')).and_return([ '/path/to/valid.yml' ])
        allow(File).to receive(:read).with('/path/to/valid.yml').and_return(valid_yaml)

        expect { Rake::Task['transformer:validate'].invoke }.to output(/All transformation files are valid./).to_stdout
      end
    end

    context 'with a file having invalid syntax' do
      it 'prints a syntax error message' do
        invalid_yaml = "name: 'invalid\ndescription: 'bad syntax'"
        allow(Dir).to receive(:glob).with(Rails.root.join('config', 'transformations', '*.yml')).and_return([ '/path/to/invalid_syntax.yml' ])
        allow(File).to receive(:read).with('/path/to/invalid_syntax.yml').and_return(invalid_yaml)

        expect { Rake::Task['transformer:validate'].invoke }.to output(/ERROR: Invalid YAML syntax in/).to_stdout
      end
    end

    context 'with a file having invalid schema' do
      it 'prints a schema error message' do
        invalid_schema_yaml = {
          'name' => 'invalid_schema',
          'description' => 'Missing version and transformations'
        }.to_yaml

        allow(Dir).to receive(:glob).with(Rails.root.join('config', 'transformations', '*.yml')).and_return([ '/path/to/invalid_schema.yml' ])
        allow(File).to receive(:read).with('/path/to/invalid_schema.yml').and_return(invalid_schema_yaml)

        # The new gem provides more specific error messages
        expect { Rake::Task['transformer:validate'].invoke }.to output(/ERROR: Schema validation failed for .*invalid_schema.yml.*required.*version.*transformations/m).to_stdout
      end
    end
  end
end
