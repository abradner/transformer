# frozen_string_literal: true

# Unified service for managing transformations from both file and database sources
# Coordinates between different adapters and provides a consistent interface
class TransformationRegistryService
  def initialize(user_id = nil)
    @user_id = user_id
    @file_adapter = FileTransformationAdapter.new
    @database_adapter = DatabaseTransformationAdapter.new(user_id)
  end

  # Load all transformations from both sources
  def load_all
    transformations = []
    errors = []

    # Load file-based transformations
    # TODO: cache file transformations to avoid repeated disk I/O
    begin
      file_transformations = @file_adapter.load_all
      transformations.concat(file_transformations)
    rescue StandardError => e
      errors << "Failed to load file transformations: #{e.message}"
    end

    # Load database transformations
    begin
      db_transformations = @database_adapter.load_all
      transformations.concat(db_transformations)
    rescue StandardError => e
      errors << "Failed to load database transformations: #{e.message}"
    end

    # Check for name conflicts
    conflicts = find_name_conflicts(transformations)
    unless conflicts.empty?
      Rails.logger.warn "Transformation name conflicts detected: #{conflicts.join(', ')}"
      # For now, database transformations take precedence over file-based ones
      transformations = resolve_conflicts(transformations)
    end

    LoadResult.new(transformations, errors)
  end

  # Load a specific transformation by name (checks both sources)
  def load_by_name(name)
    # Try database first (higher precedence)
    transformation = @database_adapter.load_by_name(name)
    return transformation if transformation

    # Fall back to file-based
    @file_adapter.load_by_name(name)
  end

  # Check if a transformation exists in either source
  def exists?(name)
    @database_adapter.exists?(name) || @file_adapter.exists?(name)
  end

  # List all available transformation names
  def available_names
    db_names = @database_adapter.available_names
    file_names = @file_adapter.available_names
    (db_names + file_names).uniq.sort
  end

  # Create a new database transformation
  def create_transformation(name:, description:, version:, transformations:)
    # Check for conflicts with file-based transformations
    if @file_adapter.exists?(name)
      raise ConflictError, "A file-based transformation with name '#{name}' already exists"
    end

    @database_adapter.create(
      name: name,
      description: description,
      version: version,
      transformations: transformations
    )
  end

  # Update a database transformation
  def update_transformation(id, attributes)
    @database_adapter.update(id, attributes)
  end

  # Delete a database transformation
  def delete_transformation(id)
    @database_adapter.delete(id)
  end

  # Get transformation by ID (database only)
  def load_by_id(id)
    @database_adapter.load_by_id(id)
  end

  # Get statistics
  def statistics
    file_count = @file_adapter.available_names.size
    db_count = @database_adapter.available_names.size
    total_count = available_names.size
    conflicts_count = file_count + db_count - total_count

    {
      total: total_count,
      file_based: file_count,
      database_persisted: db_count,
      conflicts: conflicts_count
    }
  end

  private

  def find_name_conflicts(transformations)
    name_sources = {}
    conflicts = []

    transformations.each do |transformation|
      name = transformation.name
      source = transformation.source_type

      if name_sources[name]
        conflicts << name unless conflicts.include?(name)
      else
        name_sources[name] = source
      end
    end

    conflicts
  end

  def resolve_conflicts(transformations)
    # Group by name and keep only database transformations when conflicts exist
    grouped = transformations.group_by(&:name)

    grouped.map do |name, transforms|
      if transforms.size > 1
        # Prefer database over file
        database_transform = transforms.find(&:database_persisted?)
        database_transform || transforms.first
      else
        transforms.first
      end
    end
  end

  # Result class for load operations
  class LoadResult
    attr_reader :transformations, :errors

    def initialize(transformations, errors = [])
      @transformations = transformations
      @errors = errors
    end

    def success?
      errors.empty?
    end

    def has_transformations?
      !transformations.empty?
    end

    def count
      transformations.size
    end

    def to_h
      {
        transformations: transformations.map(&:to_h),
        count: count,
        errors: errors,
        success: success?
      }
    end
  end

  class ConflictError < StandardError; end
end
