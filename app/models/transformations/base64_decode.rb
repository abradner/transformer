# frozen_string_literal: true

require 'base64'

module Transformations
  # Base64 decoding transformation
  class Base64Decode
    include Transformable

    def name
      "base64_decode"
    end

    def description
      "Decode Base64 encoded text"
    end

    def apply(input)
      Base64.strict_decode64(input)
    rescue ArgumentError => e
      raise ArgumentError, "Invalid Base64 input: #{e.message}"
    end

    def validate_input(input)
      result = super(input)
      return result unless result.valid?

      # Check if input looks like valid Base64
      if input.match?(/\A[A-Za-z0-9+\/]*={0,2}\z/) && input.length % 4 == 0
        ValidationResult.new(true, [])
      else
        ValidationResult.new(false, ["Input does not appear to be valid Base64"])
      end
    end
  end
end
