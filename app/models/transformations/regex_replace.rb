# frozen_string_literal: true

module Transformations
  # Regex replacement transformation for pattern-based text manipulation
  class RegexReplace
    include Transformable

    attr_reader :pattern, :replacement, :flags

    def initialize(pattern:, replacement:, flags: [])
      @pattern = pattern
      @replacement = replacement
      @flags = Array(flags)
    end

    def name
      "regex_replace"
    end

    def description
      "Replace text using regular expressions"
    end

    def apply(input)
      regex_flags = parse_flags(@flags)
      regex = Regexp.new(@pattern, regex_flags)
      input.gsub(regex, @replacement)
    rescue RegexpError => e
      raise ArgumentError, "Invalid regex pattern: #{e.message}"
    end

    def validate_input(input)
      result = super(input)
      return result unless result.valid?

      errors = []

      # Validate pattern
      begin
        Regexp.new(@pattern)
      rescue RegexpError => e
        errors << "Invalid regex pattern: #{e.message}"
      end

      # Validate flags
      invalid_flags = @flags - valid_flags
      errors << "Invalid flags: #{invalid_flags.join(', ')}" if invalid_flags.any?

      ValidationResult.new(errors.empty?, errors)
    end

    def configuration_schema
      super.merge(
        properties: super[:properties].merge(
          pattern: {
            type: "string",
            description: "Regular expression pattern to match"
          },
          replacement: {
            type: "string",
            description: "Replacement text (can include capture groups like $1, $2)"
          },
          flags: {
            type: "array",
            items: {
              type: "string",
              enum: valid_flags
            },
            description: "Regex flags (i=ignorecase, m=multiline, x=extended)"
          }
        ),
        required: super[:required] + ["pattern", "replacement"]
      )
    end

    private

    def valid_flags
      %w[i m x]
    end

    def parse_flags(flags)
      flag_mapping = {
        'i' => Regexp::IGNORECASE,
        'm' => Regexp::MULTILINE,
        'x' => Regexp::EXTENDED
      }

      flags.reduce(0) do |combined, flag|
        combined | (flag_mapping[flag] || 0)
      end
    end
  end
end
