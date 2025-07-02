# frozen_string_literal: true

module YamlTransformations
  # YAML wrapper for Base64 decode transformations
  class Base64DecodeTransformation < Base
    def initialize(name:, description:, version:)
      super(name: name, description: description, version: version)
      @base64_transformer = Transformations::Base64Decode.new
    end

    def apply(input)
      @base64_transformer.apply(input)
    end

    def validate_input(input)
      @base64_transformer.validate_input(input)
    end
  end
end
