# frozen_string_literal: true

require 'test_helper'

class TransformationEngineIntegrationTest < ActiveSupport::TestCase
  def setup
    @engine = TransformationEngine.new

    # Register our built-in transformations
    @engine.register(Transformations::Base64Encode.new)
    @engine.register(Transformations::Base64Decode.new)
    @engine.register(Transformations::RegexReplace.new(
      pattern: 'ERROR',
      replacement: '🚨 ERROR'
    ))
  end

  test "transformation engine can list available transformations" do
    available = @engine.available_transformations

    assert_includes available, "base64_encode"
    assert_includes available, "base64_decode"
    assert_includes available, "regex_replace"
    assert_equal 3, available.length
  end

  test "transformation engine can apply transformations by name" do
    # Test Base64 encoding
    encoded = @engine.apply("base64_encode", "Hello World!")
    assert_equal "SGVsbG8gV29ybGQh", encoded

    # Test Base64 decoding
    decoded = @engine.apply("base64_decode", "SGVsbG8gV29ybGQh")
    assert_equal "Hello World!", decoded

    # Test regex replacement
    log_line = "ERROR: Something went wrong"
    transformed = @engine.apply("regex_replace", log_line)
    assert_equal "🚨 ERROR: Something went wrong", transformed
  end

  test "transformation engine can chain transformations" do
    original = "Hello World!"

    # Chain: text -> base64 encode -> base64 decode -> back to original
    result = @engine.apply_chain(["base64_encode", "base64_decode"], original)
    assert_equal original, result
  end

  test "transformation engine validates input for specific transformations" do
    # Valid Base64 input
    valid_result = @engine.validate_input("base64_decode", "SGVsbG8=")
    assert valid_result.valid?

    # Invalid Base64 input
    invalid_result = @engine.validate_input("base64_decode", "not-base64!")
    refute invalid_result.valid?
    assert_includes invalid_result.errors.first, "Base64"
  end

  test "transformation engine handles errors gracefully" do
    # Unknown transformation
    assert_raises TransformationEngine::TransformationNotFoundError do
      @engine.apply("unknown_transformation", "test")
    end

    # Invalid input for transformation
    assert_raises ArgumentError do
      @engine.apply("base64_decode", "invalid-base64!")
    end
  end

  test "real world log parsing scenario" do
    # Register a log parsing transformation
    log_parser = Transformations::RegexReplace.new(
      pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})',
      replacement: '\1 \2'
    )
    @engine.register(log_parser)

    # Transform a realistic log line
    log_line = "2025-01-07T14:30:45 ERROR: Database connection failed"
    result = @engine.apply("regex_replace", log_line)

    assert_equal "2025-01-07 14:30:45 ERROR: Database connection failed", result
  end
end
