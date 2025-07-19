# frozen_string_literal: true

# Adapter for loading transformations from YAML files
class FileTransformationAdapter
  def initialize(transformations_path = nil)
    @transformations_path = transformations_path || Rails.root.join("config", "transformations")
  end

  # Load all file-based transformations
  def load_all
    return [] unless Dir.exist?(@transformations_path)

    Dir.glob(File.join(@transformations_path, "*.yml")).map do |file_path|
      load_from_file(file_path)
    end.compact
  end

  # Load a specific transformation by filename
  def load_by_name(name)
    file_path = File.join(@transformations_path, "#{name}.yml")
    return nil unless File.exist?(file_path)

    load_from_file(file_path)
  end

  # Check if a transformation exists
  def exists?(name)
    File.exist?(File.join(@transformations_path, "#{name}.yml"))
  end

  # List available transformation names
  def available_names
    return [] unless Dir.exist?(@transformations_path)

    Dir.glob(File.join(@transformations_path, "*.yml")).map do |file_path|
      File.basename(file_path, ".yml")
    end
  end

  private

  def load_from_file(file_path)
    yaml_content = YAML.load_file(file_path)
    validate_yaml_structure!(yaml_content, file_path)

    Domain::TransformationDefinition.new(
      name: yaml_content["name"],
      description: yaml_content["description"],
      version: yaml_content["version"] || "1.0",
      transformations: yaml_content["transformations"] || [],
      source_type: :file,
      source_id: file_path
    )
  rescue Psych::SyntaxError => e
    Rails.logger.error "Invalid YAML syntax in #{file_path}: #{e.message}"
    nil
  rescue ValidationError => e
    Rails.logger.error "Invalid transformation structure in #{file_path}: #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "Failed to load transformation from #{file_path}: #{e.message}"
    nil
  end

  def validate_yaml_structure!(yaml_content, file_path)
    unless yaml_content.is_a?(Hash)
      raise ValidationError, "Root must be a hash"
    end

    unless yaml_content["name"].present?
      raise ValidationError, "Missing required field: name"
    end

    unless yaml_content["transformations"].is_a?(Array)
      raise ValidationError, "transformations must be an array"
    end
  end

  class ValidationError < StandardError; end
end
