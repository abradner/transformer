# frozen_string_literal: true

module YamlTransformations
  # Base class for YAML-configured transformations
  class Base
    include Transformable

    attr_reader :yaml_name, :yaml_description, :yaml_version

    def initialize(name:, description:, version:)
      @yaml_name = name
      @yaml_description = description
      @yaml_version = version
    end

    def name
      @yaml_name
    end

    def description
      @yaml_description
    end

    def version
      @yaml_version
    end

    def metadata
      super.merge(
        version: @yaml_version,
        source: "yaml_configuration"
      )
    end
  end
end
