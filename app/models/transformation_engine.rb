# frozen_string_literal: true

# Core transformation engine that manages and applies string transformations
class TransformationEngine
  class TransformationNotFoundError < StandardError; end

  def initialize
    @transformations = {}
  end

  # Register a transformation with the engine
  def register(transformation)
    @transformations[transformation.name] = transformation
  end

  # Get list of available transformation names
  def available_transformations
    @transformations.keys
  end

  # Find a transformation by name
  def find_transformation(name)
    @transformations[name]
  end

  # Apply a transformation by name to input string
  def apply(transformation_name, input)
    transformation = find_transformation(transformation_name)
    raise TransformationNotFoundError, "Transformation '#{transformation_name}' not found" unless transformation

    transformation.apply(input)
  end

  # Apply multiple transformations in sequence
  def apply_chain(transformation_names, input)
    transformation_names.reduce(input) do |current_input, name|
      apply(name, current_input)
    end
  end

  # Validate input for a specific transformation
  def validate_input(transformation_name, input)
    transformation = find_transformation(transformation_name)
    raise TransformationNotFoundError, "Transformation '#{transformation_name}' not found" unless transformation

    transformation.validate_input(input)
  end
end
