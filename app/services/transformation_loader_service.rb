# frozen_string_literal: true

# Service responsible for loading and registering all available transformations
# Follows SRP by handling only transformation discovery and registration
class TransformationLoaderService
  def initialize(engine)
    @engine = engine
    @transformation_configs = []
  end

  # Load all transformations into the engine
  def load_all(user_id = nil)
    load_built_in_transformations
    load_yaml_transformations
    load_custom_transformations(user_id)
    @engine
  end

  # Get list of all available transformations with metadata
  def available_transformations
    @transformation_configs
  end

  private

  def load_built_in_transformations
    # Load simple transformations that don't require configuration
    simple_transformations = [
      Transformations::Base64Encode,
      Transformations::Base64Decode
    ]

    simple_transformations.each do |klass|
      transformation = klass.new
      @engine.register(transformation)

      @transformation_configs << {
        name: transformation.name,
        display_name: format_display_name(transformation.name),
        description: transformation.description,
        type: "built_in",
        source: klass.name
      }
    end

    # Note: RegexReplace requires configuration (pattern, replacement)
    # so it's better suited for YAML-based transformations or a dedicated UI
    Rails.logger.info "Loaded #{simple_transformations.length} built-in transformations"
  rescue StandardError => e
    Rails.logger.error "Failed to load built-in transformation: #{e.message}"
    raise TransformationLoaderError, "Built-in transformation loading failed: #{e.message}"
  end

  def load_yaml_transformations
    # Temporarily disabled for debugging - will re-enable once basic transformations work
    Rails.logger.info "YAML transformations temporarily disabled for initial setup"
    return

    yaml_dir = Rails.root.join("config", "transformations")
    return unless Dir.exist?(yaml_dir)

    Dir.glob("#{yaml_dir}/*.yml").each do |file_path|
      load_yaml_transformation(file_path)
    end
  end

  def load_yaml_transformation(file_path)
    filename = File.basename(file_path, ".yml")
    yaml_content = YAML.load_file(file_path)

    transformation = create_yaml_transformation(yaml_content)
    @engine.register(transformation)

    @transformation_configs << {
      name: transformation.name,
      display_name: yaml_content["metadata"]["display_name"] || format_display_name(transformation.name),
      description: transformation.description,
      type: "yaml",
      source: filename,
      version: transformation.version
    }
  rescue StandardError => e
    Rails.logger.warn "Failed to load YAML transformation from #{file_path}: #{e.message}"
    # Continue loading other transformations even if one fails
  end

  def create_yaml_transformation(yaml_content)
    metadata = yaml_content["metadata"]
    name = metadata["name"]
    description = metadata["description"]
    version = metadata["version"]

    base_transformation = YamlTransformations::Base.new(
      name: name,
      description: description,
      version: version
    )

    # Extend with appropriate transformation type based on YAML structure
    if yaml_content["transformation"]["type"] == "composite"
      YamlTransformations::CompositeTransformation.new(base_transformation, yaml_content)
    elsif yaml_content["transformation"]["functions"]
      YamlTransformations::FunctionBasedTransformation.new(base_transformation, yaml_content)
    else
      base_transformation
    end
  end

  def load_custom_transformations(user_id = nil)
    return unless defined?(Transformation) # Only load if Transformation model exists

    custom_loader = CustomTransformationLoaderService.new(@engine)
    result = custom_loader.load_for_user(user_id)

    # Add custom transformations to available list
    custom_loader.available_transformations(user_id).each do |transformation|
      @transformation_configs << {
        name: transformation[:name],
        display_name: transformation[:display_name],
        description: transformation[:description],
        type: "custom",
        source: "database",
        version: transformation[:version],
        system_transformation: transformation[:system_transformation],
        category: transformation[:category]
      }
    end

    Rails.logger.info "Loaded #{result.loaded_count} custom transformations"

    unless result.success?
      Rails.logger.warn "Custom transformation loading had errors: #{result.errors.join(', ')}"
    end
  rescue StandardError => e
    Rails.logger.error "Failed to load custom transformations: #{e.message}"
    # Don't raise here - we want the engine to work even if custom transformations fail
  end

  def format_display_name(name)
    name.split("_").map(&:capitalize).join(" ")
  end
end
