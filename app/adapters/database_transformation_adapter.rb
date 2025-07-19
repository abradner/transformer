# frozen_string_literal: true

# Adapter for loading transformations from database
class DatabaseTransformationAdapter
  def initialize(user_id = nil)
    @user_id = user_id
  end

  # Load all database transformations available to the user
  def load_all
    scope = @user_id ? available_for_user_scope : system_scope

    scope.map do |record|
      transform_record_to_domain(record)
    end.compact
  end

  # Load a specific transformation by name
  def load_by_name(name)
    scope = @user_id ? available_for_user_scope : system_scope
    record = scope.find_by(name: name)
    return nil unless record

    transform_record_to_domain(record)
  end

  # Load a specific transformation by ID
  def load_by_id(id)
    scope = @user_id ? available_for_user_scope : system_scope
    record = scope.find_by(id: id)
    return nil unless record

    transform_record_to_domain(record)
  end

  # Check if a transformation exists
  def exists?(name)
    scope = @user_id ? available_for_user_scope : system_scope
    scope.exists?(name: name)
  end

  # List available transformation names
  def available_names
    scope = @user_id ? available_for_user_scope : system_scope
    scope.pluck(:name)
  end

  # Create a new transformation
  def create(name:, description:, version:, transformations:)
    record = Transformation.new(
      name: name,
      description: description,
      version: version,
      transformations_yaml: transformations_to_yaml(transformations),
      transformation_type: "yaml"
    )

    if record.save
      transform_record_to_domain(record)
    else
      raise ValidationError, record.errors.full_messages.join(", ")
    end
  end

  # Update an existing transformation
  def update(id, attributes)
    record = find_record_for_update(id)

    update_attributes = prepare_update_attributes(attributes)

    if record.update(update_attributes)
      transform_record_to_domain(record)
    else
      raise ValidationError, record.errors.full_messages.join(", ")
    end
  end

  # Delete a transformation
  def delete(id)
    record = find_record_for_update(id)
    record.destroy!
    true
  end

  private

  def transform_record_to_domain(record)
    transformations = parse_transformations_yaml(record.transformations_yaml)

    Domain::TransformationDefinition.new(
      name: record.name,
      description: record.description,
      version: record.version,
      transformations: transformations,
      source_type: :database,
      source_id: record.id
    )
  rescue StandardError => e
    Rails.logger.error "Failed to transform record #{record.id} to domain: #{e.message}"
    nil
  end

  def parse_transformations_yaml(yaml_content)
    return [] if yaml_content.blank?

    YAML.safe_load(yaml_content) || []
  rescue Psych::SyntaxError => e
    Rails.logger.error "Invalid transformations YAML: #{e.message}"
    []
  end

  def transformations_to_yaml(transformations)
    YAML.dump(transformations)
  end

  def system_scope
    # For now, all transformations are system transformations
    # When we add user support, this will filter by user_id being nil
    Transformation.all
  end

  def available_for_user_scope
    # For now, same as system scope since we don't have user_id
    # When we add user support: Transformation.where("user_id IS NULL OR user_id = ?", @user_id)
    system_scope
  end

  def find_record_for_update(id)
    scope = @user_id ? available_for_user_scope : system_scope
    record = scope.find_by(id: id)
    raise NotFoundError, "Transformation not found" unless record
    record
  end

  def prepare_update_attributes(attributes)
    update_attrs = attributes.slice(:description, :version)

    if attributes.key?(:transformations)
      update_attrs[:transformations_yaml] = transformations_to_yaml(attributes[:transformations])
    end

    update_attrs
  end

  class ValidationError < StandardError; end
  class NotFoundError < StandardError; end
end
