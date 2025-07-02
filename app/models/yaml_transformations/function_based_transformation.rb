# frozen_string_literal: true

module YamlTransformations
  # Function-based transformation using Liquid templates
  class FunctionBasedTransformation < Base
    class TemplateError < StandardError; end

    def initialize(name:, description:, version:, template:, allowed_functions:, function_registry:)
      super(name: name, description: description, version: version)
      @template = template
      @allowed_functions = allowed_functions
      @function_registry = function_registry
      @liquid_template = parse_template(template)
    end

    def apply(input)
      context = build_liquid_context(input)
      result = @liquid_template.render(context)

      # Handle any rendering errors
      if @liquid_template.errors.any?
        raise TemplateError, "Template rendering failed: #{@liquid_template.errors.join(', ')}"
      end

      result
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
  end
end
