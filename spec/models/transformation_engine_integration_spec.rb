# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transformation Engine Integration', type: :model do
  let(:engine) { TransformationEngine.new }

  before do
    # Register our built-in transformations
    engine.register(Transformations::Base64Encode.new)
    engine.register(Transformations::Base64Decode.new)
    engine.register(Transformations::RegexReplace.new(
      pattern: 'ERROR',
      replacement: '🚨 ERROR'
    ))
  end

  describe 'available transformations' do
    it 'lists all registered transformations' do
      available = engine.available_transformations

      expect(available).to include("base64_encode")
      expect(available).to include("base64_decode")
      expect(available).to include("regex_replace")
      expect(available.length).to eq(3)
    end
  end

  describe 'applying transformations by name' do
    it 'applies Base64 encoding correctly' do
      encoded = engine.apply("base64_encode", "Hello World!")
      expect(encoded).to eq("SGVsbG8gV29ybGQh")
    end

    it 'applies Base64 decoding correctly' do
      decoded = engine.apply("base64_decode", "SGVsbG8gV29ybGQh")
      expect(decoded).to eq("Hello World!")
    end

    it 'applies regex replacement correctly' do
      log_line = "ERROR: Something went wrong"
      transformed = engine.apply("regex_replace", log_line)
      expect(transformed).to eq("🚨 ERROR: Something went wrong")
    end
  end

  describe 'transformation chaining' do
    it 'chains transformations correctly' do
      original = "Hello World!"

      # Chain: text -> base64 encode -> base64 decode -> back to original
      result = engine.apply_chain([ "base64_encode", "base64_decode" ], original)
      expect(result).to eq(original)
    end
  end

  describe 'input validation' do
    it 'validates valid Base64 input' do
      valid_result = engine.validate_input("base64_decode", "SGVsbG8=")
      expect(valid_result).to be_valid
    end

    it 'validates invalid Base64 input' do
      invalid_result = engine.validate_input("base64_decode", "not-base64!")
      expect(invalid_result).not_to be_valid
      expect(invalid_result.errors.first).to include("Base64")
    end
  end

  describe 'error handling' do
    it 'raises error for unknown transformation' do
      expect {
        engine.apply("unknown_transformation", "test")
      }.to raise_error(TransformationEngine::TransformationNotFoundError)
    end

    it 'raises error for invalid transformation input' do
      expect {
        engine.apply("base64_decode", "invalid-base64!")
      }.to raise_error(ArgumentError)
    end
  end

  describe 'real world scenarios' do
    it 'handles log parsing workflow' do
      # Register a log parsing transformation
      log_parser = Transformations::RegexReplace.new(
        pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})',
        replacement: '\1 \2'
      )
      engine.register(log_parser)

      # Transform a realistic log line
      log_line = "2025-01-07T14:30:45 ERROR: Database connection failed"
      result = engine.apply("regex_replace", log_line)

      expect(result).to eq("2025-01-07 14:30:45 ERROR: Database connection failed")
    end
  end
end
