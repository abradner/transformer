# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transformations::RegexReplace, type: :model do
  let(:simple_regex) { described_class.new(pattern: "test", replacement: "demo") }

  describe '#name and #description' do
    it 'has correct transformation metadata' do
      expect(simple_regex.name).to eq("regex_replace")
      expect(simple_regex.description).to eq("Replace text using regular expressions")
    end
  end

  describe '#apply' do
    context 'with simple replacement' do
      let(:regex) { described_class.new(pattern: "world", replacement: "universe") }

      it 'replaces text correctly' do
        result = regex.apply("Hello world!")
        expect(result).to eq("Hello universe!")
      end
    end

    context 'with capture groups' do
      let(:date_regex) do
        described_class.new(
          pattern: '(\d{4})-(\d{2})-(\d{2})',
          replacement: '\3/\2/\1'
        )
      end

      it 'handles capture group replacements' do
        result = date_regex.apply("Date: 2025-01-07")
        expect(result).to eq("Date: 07/01/2025")
      end
    end

    context 'with flags' do
      let(:case_insensitive_regex) do
        described_class.new(
          pattern: "HELLO",
          replacement: "Hi",
          flags: [ "i" ]
        )
      end

      it 'applies case insensitive matching' do
        result = case_insensitive_regex.apply("hello world")
        expect(result).to eq("Hi world")
      end
    end

    context 'with log parsing' do
      let(:log_regex) do
        described_class.new(
          pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})',
          replacement: '\1 \2'
        )
      end

      it 'transforms ISO timestamps to readable format' do
        log_line = "2025-01-07T14:30:45 INFO User logged in"
        result = log_regex.apply(log_line)
        expect(result).to eq("2025-01-07 14:30:45 INFO User logged in")
      end
    end
  end

  describe '#validate_input' do
    it 'validates input correctly for valid patterns' do
      expect(simple_regex.validate_input("test input")).to be_valid
    end

    context 'with invalid pattern' do
      let(:invalid_regex) do
        described_class.new(pattern: "[invalid", replacement: "test")
      end

      it 'returns validation errors for invalid regex' do
        validation = invalid_regex.validate_input("test")
        expect(validation).not_to be_valid
        expect(validation.error_message).to include("Invalid regex pattern")
      end
    end

    context 'with invalid flags' do
      let(:invalid_flags_regex) do
        described_class.new(
          pattern: "test",
          replacement: "demo",
          flags: [ "invalid", "z" ]
        )
      end

      it 'returns validation errors for invalid flags' do
        validation = invalid_flags_regex.validate_input("test")
        expect(validation).not_to be_valid
        expect(validation.error_message).to include("Invalid flags")
      end
    end
  end

  describe '#configuration_schema' do
    it 'includes required fields in schema' do
      schema = simple_regex.configuration_schema

      expect(schema[:required]).to include("pattern")
      expect(schema[:required]).to include("replacement")
      expect(schema[:properties][:pattern][:type]).to eq("string")
      expect(schema[:properties][:replacement][:type]).to eq("string")
    end
  end
end
