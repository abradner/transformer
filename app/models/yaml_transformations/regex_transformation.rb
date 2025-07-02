# frozen_string_literal: true

module YamlTransformations
  # YAML wrapper for regex transformations
  class RegexTransformation < Base
    def initialize(name:, description:, version:, pattern:, replacement:, flags: [])
      super(name: name, description: description, version: version)
      @regex_transformer = Transformations::RegexReplace.new(
        pattern: pattern,
        replacement: replacement,
        flags: flags
      )
    end

    def apply(input)
      @regex_transformer.apply(input)
    end

    def validate_input(input)
      @regex_transformer.validate_input(input)
    end

    def configuration_schema
      @regex_transformer.configuration_schema.merge(
        properties: @regex_transformer.configuration_schema[:properties].merge(
          version: { type: "string" }
        )
      )
    end
  end
end
