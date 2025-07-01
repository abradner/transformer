# frozen_string_literal: true

# Represents the result of validating input for a transformation
class ValidationResult
  attr_reader :errors

  def initialize(valid, errors = [])
    @valid = valid
    @errors = Array(errors)
  end

  # @return [Boolean] true if validation passed
  def valid?
    @valid
  end

  # @return [Boolean] true if validation failed
  def invalid?
    !valid?
  end

  # @return [String] human-readable error message
  def error_message
    errors.join(", ")
  end

  # @return [Hash] JSON representation of validation result
  def to_h
    {
      valid: valid?,
      errors: errors
    }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end
end
