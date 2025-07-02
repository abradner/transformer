# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransformationEngine, type: :model do
  describe 'transformation interface contract' do
    let(:transformation) { MockTransformation.new }

    it 'responds to required methods' do
      expect(transformation).to respond_to(:apply)
      expect(transformation).to respond_to(:name)
      expect(transformation).to respond_to(:description)
      expect(transformation).to respond_to(:validate_input)
      expect(transformation).to respond_to(:configuration_schema)
    end

    it 'returns string from apply method' do
      result = transformation.apply("test input")

      expect(result).to be_a(String)
      expect(result).not_to eq("test input") # Should transform the input
    end

    it 'has human readable name and description' do
      expect(transformation.name).to be_a(String)
      expect(transformation.description).to be_a(String)
      expect(transformation.name.length).to be > 0
      expect(transformation.description.length).to be > 0
    end

    it 'validates input properly' do
      valid_result = transformation.validate_input("valid input")
      invalid_result = transformation.validate_input("")

      expect(valid_result).to respond_to(:valid?)
      expect(valid_result).to respond_to(:errors)
      expect(valid_result).to be_valid
      expect(invalid_result).not_to be_valid
    end

    it 'has configuration schema' do
      schema = transformation.configuration_schema

      expect(schema).to be_a(Hash)
      expect(schema).to have_key(:type)
      expect(schema).to have_key(:properties)
    end
  end

  describe 'engine functionality' do
    let(:engine) { TransformationEngine.new }
    let(:transformation) { MockTransformation.new }

    it 'can register transformations' do
      engine.register(transformation)

      expect(engine.available_transformations).to include(transformation.name)
      expect(engine.find_transformation(transformation.name)).to eq(transformation)
    end

    it 'can apply transformation by name' do
      engine.register(transformation)

      result = engine.apply(transformation.name, "test input")

      expect(result).to eq(transformation.apply("test input"))
    end

    it 'handles unknown transformation' do
      expect {
        engine.apply("unknown_transformation", "test input")
      }.to raise_error(TransformationEngine::TransformationNotFoundError)
    end
  end

  # Mock transformation class for testing
  class MockTransformation
    def name
      "mock_transformation"
    end

    def description
      "A mock transformation for testing"
    end

    def apply(input)
      "transformed: #{input}"
    end

    def validate_input(input)
      if input.nil? || input.empty?
        ValidationResult.new(false, [ "Input cannot be empty" ])
      else
        ValidationResult.new(true, [])
      end
    end

    def configuration_schema
      {
        type: "object",
        properties: {
          name: { type: "string" },
          description: { type: "string" }
        },
        required: [ "name" ]
      }
    end
  end
end
