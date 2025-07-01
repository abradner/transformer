# frozen_string_literal: true

# Base module that defines the interface for all transformations
module Transformable
  extend ActiveSupport::Concern

  included do
    # All transformations must implement these methods
  end

  # Apply the transformation to the input string
  # @param input [String] the string to transform
  # @return [String] the transformed string
  def apply(input)
    raise NotImplementedError, "#{self.class} must implement #apply"
  end

  # Human-readable name for this transformation
  # @return [String] the transformation name
  def name
    raise NotImplementedError, "#{self.class} must implement #name"
  end

  # Human-readable description of what this transformation does
  # @return [String] the transformation description
  def description
    raise NotImplementedError, "#{self.class} must implement #description"
  end

  # Validate that the input is suitable for this transformation
  # @param input [String] the input to validate
  # @return [ValidationResult] validation result with errors if any
  def validate_input(input)
    if input.nil?
      ValidationResult.new(false, ["Input cannot be nil"])
    elsif !input.is_a?(String)
      ValidationResult.new(false, ["Input must be a string"])
    else
      ValidationResult.new(true, [])
    end
  end

  # Get the JSON schema for this transformation's configuration
  # @return [Hash] JSON schema describing configuration options
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

  # Whether this transformation can be chained with others
  # @return [Boolean] true if chainable
  def chainable?
    true
  end

  # Get metadata about this transformation
  # @return [Hash] metadata including name, description, schema
  def metadata
    {
      name: name,
      description: description,
      chainable: chainable?,
      schema: configuration_schema
    }
  end
end
