# frozen_string_literal: true

require "json_schemer"

# The Transformer module provides a namespace for all transformation-related logic.
module Transformer
  # The Validator class is responsible for validating YAML transformation files.
  class Validator
    def self.validate_all
      schema_path = Rails.root.join("docs", "schemas", "transformation_schema.json")
      schema = Pathname.new(schema_path)
      schemer = JSONSchemer.schema(schema)

      files = Dir.glob(Rails.root.join("config", "transformations", "*.yml"))
      errors = []

      files.each do |file_path|
        errors.concat(validate_file(file_path, schemer))
      end

      if errors.empty?
        puts "All transformation files are valid."
        true
      else
        puts errors.join("\n")
        false
      end
    end

    def self.validate_file(file_path, schemer)
      errors = []
      begin
        file_content = File.read(file_path)
        data = YAML.safe_load(file_content, permitted_classes: [ Symbol ], aliases: true)
        validation_errors = schemer.validate(data).to_a
        return [] if validation_errors.empty?

        errors << "ERROR: Schema validation failed for #{file_path}:"
        errors.concat(validation_errors.map do |e|
          "  - Error: `#{e['type']}` - `#{e['error']}` at `#{e['data_pointer']}`"
        end)
      rescue Psych::SyntaxError => e
        errors << "ERROR: Invalid YAML syntax in #{file_path}: #{e.message}"
      end
      errors
    end

    def validate_yaml_string(yaml_content)
      schema_path = Rails.root.join("docs", "schemas", "transformation_schema.json")
      schema = Pathname.new(schema_path)
      schemer = JSONSchemer.schema(schema)

      begin
        data = YAML.safe_load(yaml_content)
        validation_errors = schemer.validate(data).map do |e|
          "#{e['type']} - #{e['error']} at #{e['data_pointer']}"
        end

        ValidationResult.new(validation_errors.empty?, validation_errors)
      rescue Psych::SyntaxError => e
        ValidationResult.new(false, [ "Invalid YAML syntax: #{e.message}" ])
      rescue StandardError => e
        ValidationResult.new(false, [ "Validation error: #{e.message}" ])
      end
    end
  end
end

# Simple result class for validation results
class ValidationResult
  attr_reader :errors

  def initialize(valid, errors = [])
    @valid = valid
    @errors = errors
  end

  def valid?
    @valid
  end

  def invalid?
    !@valid
  end
end
