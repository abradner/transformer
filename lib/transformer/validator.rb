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
  end
end
