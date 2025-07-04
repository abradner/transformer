# frozen_string_literal: true

require "json_schemer"

require_relative "../transformer/validator"

namespace :transformer do
  desc "Lists all available YAML transformations"
  task list: :environment do
    puts "Available Transformations:"
    path = Rails.root.join("config", "transformations", "*.yml")
    Dir.glob(path).each do |file|
      puts "  - #{File.basename(file, '.yml')}"
    end
  end

  desc "Validates all YAML transformation files against the schema"
  task validate: :environment do
    exit 1 unless Transformer::Validator.validate_all
  end
end
