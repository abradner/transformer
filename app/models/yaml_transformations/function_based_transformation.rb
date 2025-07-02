# frozen_string_literal: true

module YamlTransformations
  # Function-based transformation using Liquid templates
  class FunctionBasedTransformation < Base
    class TemplateError < StandardError; end

    def initialize(name:, description:, version:, template:, allowed_functions:, function_registry:, line_range: nil)
      super(name: name, description: description, version: version)
      @template = template
      @allowed_functions = allowed_functions
      @function_registry = function_registry
      @line_range = line_range
      @liquid_template = parse_template(template)
    end

    def apply(input)
      processed_input = @line_range ? filter_lines(input) : input
      context = build_liquid_context(processed_input)
      result = @liquid_template.render(context)

      # Handle any rendering errors
      if @liquid_template.errors.any?
        raise TemplateError, "Template rendering failed: #{@liquid_template.errors.join(', ')}"
      end

      # If we filtered lines, we need to reconstruct the full output
      @line_range ? reconstruct_output(input, result) : result
    rescue Liquid::Error => e
      raise TemplateError, "Liquid template error: #{e.message}"
    end

    def validate_input(input)
      result = super(input)
      return result unless result.valid?

      errors = []

      # Validate that all functions in allowed_functions are whitelisted
      @allowed_functions.each do |function_name|
        unless @function_registry.function_whitelisted?(function_name)
          errors << "Function '#{function_name}' is not whitelisted"
        end
      end

      # Validate that template only uses allowed functions
      template_functions = extract_functions_from_template(@template)
      unauthorized_functions = template_functions - @allowed_functions

      if unauthorized_functions.any?
        errors << "Template contains unauthorized functions: #{unauthorized_functions.join(', ')}"
      end

      ValidationResult.new(errors.empty?, errors)
    end

    private

    def parse_template(template_string)
      Liquid::Template.parse(template_string)
    rescue Liquid::SyntaxError => e
      raise TemplateError, "Invalid Liquid template syntax: #{e.message}"
    end

    def build_liquid_context(input)
      {
        "input" => input,
        "previous" => input
      }
    end

    def extract_functions_from_template(template_string)
      # Simple regex to extract function names from Liquid template
      # Matches patterns like: | function_name or | function_name(args)
      functions = []
      template_string.scan(/\|\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*(?:\(|$|\s|\|)/) do |match|
        functions << match[0]
      end
      functions.uniq
    end

    def filter_lines(input)
      lines = input.split("\n")
      return input unless @line_range

      start_pattern = @line_range["start_pattern"]
      stop_pattern = @line_range["stop_pattern"]
      include_boundaries = @line_range.fetch("include_boundaries", false)

      return input unless start_pattern

      filtered_lines = []
      in_range = false

      lines.each do |line|
        if !in_range && line.match?(Regexp.new(start_pattern))
          in_range = true
          filtered_lines << line if include_boundaries
        elsif in_range && stop_pattern && line.match?(Regexp.new(stop_pattern))
          filtered_lines << line if include_boundaries
          break
        elsif in_range
          filtered_lines << line
        end
      end

      filtered_lines.join("\n")
    end

    def reconstruct_output(original_input, processed_result)
      return processed_result unless @line_range

      original_lines = original_input.split("\n")
      processed_lines = processed_result.split("\n")
      start_pattern = @line_range["start_pattern"]
      stop_pattern = @line_range["stop_pattern"]

      return processed_result unless start_pattern

      result_lines = []
      processed_index = 0
      in_range = false

      original_lines.each do |line|
        if !in_range && line.match?(Regexp.new(start_pattern))
          in_range = true
          result_lines << line # Keep the boundary line as-is
        elsif in_range && stop_pattern && line.match?(Regexp.new(stop_pattern))
          in_range = false
          result_lines << line # Keep the boundary line as-is
        elsif in_range && processed_index < processed_lines.length
          # Replace with processed version
          result_lines << processed_lines[processed_index]
          processed_index += 1
        else
          # Keep original line
          result_lines << line
        end
      end

      result_lines.join("\n")
    end
  end
end
