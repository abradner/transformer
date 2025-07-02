# frozen_string_literal: true

require "base64"

module Transformations
  # Base64 encoding transformation
  class Base64Encode
    include Transformable

    def name
      "base64_encode"
    end

    def description
      "Encode text using Base64 encoding"
    end

    def apply(input)
      Base64.strict_encode64(input)
    end

    def validate_input(input)
      result = super(input)
      return result unless result.valid?

      # Base64 encoding can handle any string
      ValidationResult.new(true, [])
    end

    def configuration_schema
      super.merge(
        properties: super[:properties].merge(
          encoding: {
            type: "string",
            enum: [ "strict", "urlsafe" ],
            default: "strict"
          }
        )
      )
    end
  end
end
