# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transformations::Base64Encode, type: :model do
  let(:encoder) { described_class.new }

  describe '#name and #description' do
    it 'has correct transformation metadata' do
      expect(encoder.name).to eq("base64_encode")
      expect(encoder.description).to eq("Encode text using Base64 encoding")
    end
  end

  describe '#apply' do
    it 'encodes text correctly' do
      input = "Hello, World!"
      expected = Base64.strict_encode64(input)

      expect(encoder.apply(input)).to eq(expected)
      expect(encoder.apply(input)).to eq("SGVsbG8sIFdvcmxkIQ==")
    end
  end

  describe '#validate_input' do
    it 'validates input correctly' do
      expect(encoder.validate_input("test")).to be_valid
    end
  end
end

RSpec.describe Transformations::Base64Decode, type: :model do
  let(:decoder) { described_class.new }

  describe '#name and #description' do
    it 'has correct transformation metadata' do
      expect(decoder.name).to eq("base64_decode")
      expect(decoder.description).to eq("Decode Base64 encoded text")
    end
  end

  describe '#apply' do
    it 'decodes text correctly' do
      encoded = "SGVsbG8sIFdvcmxkIQ=="
      expected = "Hello, World!"

      expect(decoder.apply(encoded)).to eq(expected)
    end

    it 'raises error for invalid input' do
      expect {
        decoder.apply("invalid-base64!")
      }.to raise_error(ArgumentError, /Invalid Base64 input/)
    end
  end

  describe '#validate_input' do
    it 'validates Base64 format correctly' do
      valid_result = decoder.validate_input("SGVsbG8sIFdvcmxkIQ==")
      invalid_result = decoder.validate_input("not-base64!")

      expect(valid_result).to be_valid
      expect(invalid_result).not_to be_valid
      expect(invalid_result.errors.first).to include("valid Base64")
    end
  end

  describe 'reversibility' do
    let(:encoder) { Transformations::Base64Encode.new }

    it 'encodes and decodes reversibly' do
      original = "Hello, World!"
      encoded = encoder.apply(original)
      decoded = decoder.apply(encoded)

      expect(decoded).to eq(original)
    end
  end
end
