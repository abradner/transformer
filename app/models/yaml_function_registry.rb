# frozen_string_literal: true

require 'base64'

# Registry for whitelisted functions that can be called from YAML transformations
class YamlFunctionRegistry
  class UnauthorizedFunctionError < StandardError; end

  WHITELIST = %w[
    base64_encode
    base64_decode
    split_lines
    join_lines
    map_values
    filter_lines
    parse_kv_pair
    upcase
    downcase
    strip
    gsub
  ].freeze

  def call_function(function_name, *args)
    unless WHITELIST.include?(function_name.to_s)
      raise UnauthorizedFunctionError, "Function '#{function_name}' is not whitelisted"
    end

    case function_name.to_s
    when 'base64_encode'
      Base64.strict_encode64(args.first.to_s)
    when 'base64_decode'
      Base64.strict_decode64(args.first.to_s)
    when 'split_lines'
      args.first.to_s.split("\n")
    when 'join_lines'
      args.first.join("\n")
    when 'map_values'
      # This is a simplified implementation
      # In a real system, this would be more sophisticated
      args.first.map { |item| yield(item) if block_given? }
    when 'filter_lines'
      args.first.select { |line| !line.strip.empty? }
    when 'parse_kv_pair'
      line = args.first.to_s
      if line.match(/^\s*([^:]+):\s*(.+)\s*$/)
        { key: $1.strip, value: $2.strip }
      else
        { key: nil, value: line }
      end
    when 'upcase'
      args.first.to_s.upcase
    when 'downcase'
      args.first.to_s.downcase
    when 'strip'
      args.first.to_s.strip
    when 'gsub'
      pattern, replacement = args[1], args[2]
      args.first.to_s.gsub(pattern, replacement)
    else
      raise UnauthorizedFunctionError, "Function '#{function_name}' not implemented"
    end
  rescue ArgumentError => e
    raise UnauthorizedFunctionError, "Error executing '#{function_name}': #{e.message}"
  end

  def whitelisted_functions
    WHITELIST.dup
  end

  def function_whitelisted?(function_name)
    WHITELIST.include?(function_name.to_s)
  end
end
