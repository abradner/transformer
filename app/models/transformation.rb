# frozen_string_literal: true

# Simplified Transformation model focused only on persistence
# Business logic is handled by domain services and adapters
class Transformation < ApplicationRecord
  # Basic validations
  validates :name, presence: true,
                   length: { minimum: 1, maximum: 100 },
                   format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows alphanumeric, underscore, and dash characters" },
                   uniqueness: true

  validates :transformations_yaml, presence: true
  validates :transformation_type, presence: true, inclusion: { in: %w[yaml built_in] }
  validates :version, presence: true, format: { with: /\A\d+\.\d+(\.\d+)?(-\w+)?\z/, message: "must be valid semver (e.g., 1.0.0, 2.1.0-beta)" }

  # Custom validations
  validate :transformations_yaml_is_valid

  # Callbacks
  before_validation :normalize_name
  before_save :increment_patch_version_if_transformations_changed

  # Scopes for future use
  scope :by_type, ->(type) { where(transformation_type: type) }
  scope :by_version_prefix, ->(prefix) { where("version LIKE ?", "#{prefix}%") }

  def display_name
    name.humanize
  end

  def parsed_transformations
    @parsed_transformations ||= YAML.safe_load(transformations_yaml) || []
  rescue Psych::SyntaxError
    []
  end

  # Generate full YAML structure compatible with file-based transformations
  def to_full_yaml
    {
      "name" => name,
      "description" => description,
      "version" => version,
      "transformations" => parsed_transformations
    }.to_yaml
  end

  private

  def normalize_name
    self.name = name&.strip&.downcase&.gsub(/[^a-zA-Z0-9_-]/, "_")
  end

  def increment_patch_version_if_transformations_changed
    return unless persisted? && transformations_yaml_changed?

    self.version = increment_patch_version(version)
  end

  def increment_patch_version(version_string)
    parts = version_string.split(".")
    major, minor, patch = parts[0].to_i, parts[1].to_i, (parts[2] || "0").to_i
    "#{major}.#{minor}.#{patch + 1}"
  end

  def transformations_yaml_is_valid
    return if transformations_yaml.blank?

    parsed = YAML.safe_load(transformations_yaml)
    unless parsed.is_a?(Array)
      errors.add(:transformations_yaml, "must be a valid YAML array")
      return
    end

    # Basic structure validation
    parsed.each_with_index do |transformation, index|
      unless transformation.is_a?(Hash) && transformation["type"].present?
        errors.add(:transformations_yaml, "transformation at index #{index} must have a 'type' field")
      end
    end
  rescue Psych::SyntaxError => e
    errors.add(:transformations_yaml, "is not valid YAML: #{e.message}")
  end
end
