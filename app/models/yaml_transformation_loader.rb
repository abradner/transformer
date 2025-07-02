# frozen_string_literal: true

require "yaml"
require "liquid"

# Service class that loads and creates transformations from YAML configuration files
class YamlTransformationLoader
  class InvalidYamlError < StandardError; end
  class ValidationError < StandardError; end
  class FileNotFoundError < StandardError; end
  class UnknownTransformationTypeError < StandardError; end

  REQUIRED_FIELDS = %w[name description version transformations].freeze

  def initialize(function_registry = nil)
    @function_registry = function_registry || YamlFunctionRegistry.new
  end

  # Load transformation from YAML string
  def load_from_string(yaml_content)
    config = parse_yaml(yaml_content)
    validate_config(config)
    build_transformation(config)
  end

  # Load transformation from YAML file
  def load_from_file(file_path)
    unless File.exist?(file_path)
      raise FileNotFoundError, "Transformation file not found: #{file_path}"
    end

    yaml_content = File.read(file_path)
    load_from_string(yaml_content)
  end

  # Load all transformations from a directory
  def load_from_directory(directory_path)
    return [] unless Dir.exist?(directory_path)

    Dir.glob(File.join(directory_path, "*.yml")).map do |file_path|
      load_from_file(file_path)
    end
  end

  private

  def parse_yaml(yaml_content)
    YAML.safe_load(yaml_content)
  rescue Psych::SyntaxError => e
    raise InvalidYamlError, "YAML syntax error: #{e.message}"
  end

  def validate_config(config)
    missing_fields = REQUIRED_FIELDS.reject { |field| config.key?(field) }

    if missing_fields.any?
      raise ValidationError, "Missing required fields: #{missing_fields.join(', ')}"
    end

    unless config["transformations"].is_a?(Array) && config["transformations"].any?
      raise ValidationError, "transformations must be a non-empty array"
    end
  end

  def build_transformation(config)
    if config["transformations"].length == 1
      # Single transformation
      transformation_config = config["transformations"].first
      build_single_transformation(config, transformation_config)
    else
      # Multi-step transformation
      YamlTransformations::CompositeTransformation.new(
        name: config["name"],
        description: config["description"],
        version: config["version"],
        transformations: config["transformations"].map { |t| build_single_transformation(config, t) }
      )
    end
  end

  def build_single_transformation(config, transformation_config)
    case transformation_config["type"]
    when "regex_replace"
      build_regex_transformation(config, transformation_config)
    when "base64_encode"
      build_base64_encode_transformation(config)
    when "base64_decode"
      build_base64_decode_transformation(config)
    when "function_based"
      build_function_based_transformation(config, transformation_config)
    else
      raise UnknownTransformationTypeError,
            "Unknown transformation type: #{transformation_config['type']}"
    end
  end

  def build_regex_transformation(config, transformation_config)
    YamlTransformations::RegexTransformation.new(
      name: config["name"],
      description: config["description"],
      version: config["version"],
      pattern: transformation_config.dig("config", "pattern"),
      replacement: transformation_config.dig("config", "replacement"),
      flags: transformation_config.dig("config", "flags") || []
    )
  end

  def build_base64_encode_transformation(config)
    YamlTransformations::Base64EncodeTransformation.new(
      name: config["name"],
      description: config["description"],
      version: config["version"]
    )
  end

  def build_base64_decode_transformation(config)
    YamlTransformations::Base64DecodeTransformation.new(
      name: config["name"],
      description: config["description"],
      version: config["version"]
    )
  end

  def build_function_based_transformation(config, transformation_config)
    YamlTransformations::FunctionBasedTransformation.new(
      name: config["name"],
      description: config["description"],
      version: config["version"],
      template: transformation_config.dig("config", "template"),
      allowed_functions: transformation_config.dig("config", "allowed_functions") || [],
      function_registry: @function_registry
    )
  end
end
