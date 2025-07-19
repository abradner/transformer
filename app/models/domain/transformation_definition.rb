# frozen_string_literal: true

module Domain
  # Domain model representing a transformation definition
  # Abstracts away the source (file-based or database-persisted)
  class TransformationDefinition
    attr_reader :name, :description, :version, :transformations, :source_type, :source_id

    def initialize(name:, description:, version:, transformations:, source_type:, source_id: nil)
      @name = name
      @description = description
      @version = version
      @transformations = transformations
      @source_type = source_type # :file or :database
      @source_id = source_id # file path or database ID
    end

    def display_name
      name.humanize
    end

    def file_based?
      source_type == :file
    end

    def database_persisted?
      source_type == :database
    end

    def system_transformation?
      # File-based are always system, database ones depend on user_id
      file_based? || (database_persisted? && user_id.nil?)
    end

    def user_transformation?
      !system_transformation?
    end

    # Convert to the YAML structure expected by the engine
    def to_yaml_structure
      {
        "name" => name,
        "description" => description,
        "version" => version,
        "transformations" => transformations
      }
    end

    # Convert to hash for API responses
    def to_h
      {
        name: name,
        display_name: display_name,
        description: description,
        version: version,
        source_type: source_type,
        source_id: source_id,
        system_transformation: system_transformation?,
        transformations: transformations
      }
    end

    def ==(other)
      other.is_a?(self.class) &&
        name == other.name &&
        version == other.version &&
        source_type == other.source_type
    end

    alias eql? ==

    def hash
      [ name, version, source_type ].hash
    end

    private

    # For database-persisted transformations, this would come from the adapter
    # For now, we'll assume system transformations
    def user_id
      nil
    end
  end
end
