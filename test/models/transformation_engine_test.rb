# frozen_string_literal: true

require 'test_helper'

class TransformationEngineTest < ActiveSupport::TestCase
  test "transformation interface contract" do
    # Every transformation should respond to these methods
    transformation = MockTransformation.new

    assert_respond_to transformation, :apply
    assert_respond_to transformation, :name
    assert_respond_to transformation, :description
    assert_respond_to transformation, :validate_input
    assert_respond_to transformation, :configuration_schema
  end

  test "transformation apply method returns string" do
    transformation = MockTransformation.new
    result = transformation.apply("test input")

    assert_kind_of String, result
    refute_equal "test input", result # Should transform the input
  end

  test "transformation has human readable name and description" do
    transformation = MockTransformation.new

    assert_kind_of String, transformation.name
    assert_kind_of String, transformation.description
    assert transformation.name.length > 0
    assert transformation.description.length > 0
  end

  test "transformation validates input properly" do
    transformation = MockTransformation.new

    # Should return validation result object
    valid_result = transformation.validate_input("valid input")
    invalid_result = transformation.validate_input("")

    assert_respond_to valid_result, :valid?
    assert_respond_to valid_result, :errors
    assert valid_result.valid?
    refute invalid_result.valid?
  end

  test "transformation has configuration schema" do
    transformation = MockTransformation.new
    schema = transformation.configuration_schema

    assert_kind_of Hash, schema
    assert schema.key?(:type)
    assert schema.key?(:properties)
  end

  test "transformation engine can register transformations" do
    engine = TransformationEngine.new
    transformation = MockTransformation.new

    engine.register(transformation)

    assert_includes engine.available_transformations, transformation.name
    assert_equal transformation, engine.find_transformation(transformation.name)
  end

  test "transformation engine can apply transformation by name" do
    engine = TransformationEngine.new
    transformation = MockTransformation.new
    engine.register(transformation)

    result = engine.apply(transformation.name, "test input")

    assert_equal transformation.apply("test input"), result
  end

  test "transformation engine handles unknown transformation" do
    engine = TransformationEngine.new

    assert_raises TransformationEngine::TransformationNotFoundError do
      engine.apply("unknown_transformation", "test input")
    end
  end

  private

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
        ValidationResult.new(false, ["Input cannot be empty"])
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
        required: ["name"]
      }
    end
  end

  class ValidationResult
    attr_reader :errors

    def initialize(valid, errors = [])
      @valid = valid
      @errors = errors
    end

    def valid?
      @valid
    end
  end
end
