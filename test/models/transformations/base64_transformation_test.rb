# frozen_string_literal: true

require 'test_helper'

class Base64TransformationTest < ActiveSupport::TestCase
  def setup
    @encoder = Transformations::Base64Encode.new
    @decoder = Transformations::Base64Decode.new
  end

  test "base64 encode transformation interface" do
    assert_equal "base64_encode", @encoder.name
    assert_equal "Encode text using Base64 encoding", @encoder.description
    assert @encoder.validate_input("test").valid?
  end

  test "base64 encode applies correctly" do
    input = "Hello, World!"
    expected = Base64.strict_encode64(input)

    assert_equal expected, @encoder.apply(input)
    assert_equal "SGVsbG8sIFdvcmxkIQ==", @encoder.apply(input)
  end

  test "base64 decode transformation interface" do
    assert_equal "base64_decode", @decoder.name
    assert_equal "Decode Base64 encoded text", @decoder.description
  end

  test "base64 decode applies correctly" do
    encoded = "SGVsbG8sIFdvcmxkIQ=="
    expected = "Hello, World!"

    assert_equal expected, @decoder.apply(encoded)
  end

  test "base64 decode validates input format" do
    valid_result = @decoder.validate_input("SGVsbG8sIFdvcmxkIQ==")
    invalid_result = @decoder.validate_input("not-base64!")

    assert valid_result.valid?
    refute invalid_result.valid?
    assert_includes invalid_result.errors.first, "valid Base64"
  end

  test "base64 decode handles invalid input" do
    assert_raises ArgumentError do
      @decoder.apply("invalid-base64!")
    end
  end

  test "base64 transformations are reversible" do
    original = "Hello, World!"  # Using ASCII string to avoid encoding issues
    encoded = @encoder.apply(original)
    decoded = @decoder.apply(encoded)

    assert_equal original, decoded
  end
end
