# frozen_string_literal: true

require 'json_schemer'

namespace :transformer do
  desc "Lists all available YAML transformations"
  task list: :environment do
    puts "Available Transformations:"
    path = Rails.root.join('config', 'transformations', '*.yml')
    Dir.glob(path).each do |file|
      puts "  - #{File.basename(file, '.yml')}"
    end
  end

  desc "Validates all YAML transformation files against the schema"
  task validate: :environment do
    schema_path = Rails.root.join('docs', 'schemas', 'transformation_schema.json')
    schema = Pathname.new(schema_path)
    schemer = JSONSchemer.schema(schema)

    files = Dir.glob(Rails.root.join('config', 'transformations', '*.yml'))
    errors = []

    files.each do |file_path|
      begin
        file_content = File.read(file_path)
        data = YAML.safe_load(file_content, permitted_classes: [Symbol], aliases: true)
        validation_errors = schemer.validate(data).to_a
        next if validation_errors.empty?

        errors << "ERROR: Schema validation failed for #{file_path}:"
        # Format the errors to be more readable
        errors.concat(validation_errors.map do |e|
          "  - Error: `#{e['type']}` - `#{e['error']}` at `#{e['data_pointer']}`"
        end)
      rescue Psych::SyntaxError => e
        errors << "ERROR: Invalid YAML syntax in #{file_path}: #{e.message}"
      end
    end

    if errors.empty?
      puts "All transformation files are valid."
    else
      puts errors.join("\n")
      exit 1 # Fail the rake task if there are errors
    end
  end
end
