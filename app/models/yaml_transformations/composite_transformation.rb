# frozen_string_literal: true

module YamlTransformations
  # Composite transformation that applies multiple transformations in sequence
  class CompositeTransformation < Base
    def initialize(name:, description:, version:, transformations:)
      super(name: name, description: description, version: version)
      @transformations = transformations
    end

    def apply(input)
      @transformations.reduce(input) do |current_input, transformation|
        transformation.apply(current_input)
      end
    end

    def validate_input(input)
      return ValidationResult.new(true, []) if @transformations.empty?

      @transformations.first.validate_input(input)
    end

    def chainable?
      true
    end

    def metadata
      super.merge(
        transformation_count: @transformations.length,
        transformation_types: @transformations.map(&:class).map(&:name)
      )
    end
  end
end
