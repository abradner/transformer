# frozen_string_literal: true

require 'test_helper'

class RegexTransformationTest < ActiveSupport::TestCase
  test "regex transformation interface" do
    regex = Transformations::RegexReplace.new(pattern: "test", replacement: "demo")

    assert_equal "regex_replace", regex.name
    assert_equal "Replace text using regular expressions", regex.description
    assert regex.validate_input("test input").valid?
  end

  test "simple regex replacement" do
    regex = Transformations::RegexReplace.new(pattern: "world", replacement: "universe")
    result = regex.apply("Hello world!")

    assert_equal "Hello universe!", result
  end

  test "regex with capture groups" do
    regex = Transformations::RegexReplace.new(
      pattern: '(\d{4})-(\d{2})-(\d{2})',
      replacement: '\3/\2/\1'
    )
    result = regex.apply("Date: 2025-01-07")

    assert_equal "Date: 07/01/2025", result
  end

  test "regex with case insensitive flag" do
    regex = Transformations::RegexReplace.new(
      pattern: "HELLO",
      replacement: "Hi",
      flags: ["i"]
    )
    result = regex.apply("hello world")

    assert_equal "Hi world", result
  end

  test "regex validates pattern syntax" do
    invalid_regex = Transformations::RegexReplace.new(
      pattern: "[invalid",
      replacement: "test"
    )

    validation = invalid_regex.validate_input("test")
    refute validation.valid?
    assert_includes validation.error_message, "Invalid regex pattern"
  end

  test "regex validates flags" do
    invalid_flags = Transformations::RegexReplace.new(
      pattern: "test",
      replacement: "demo",
      flags: ["invalid", "z"]
    )

    validation = invalid_flags.validate_input("test")
    refute validation.valid?
    assert_includes validation.error_message, "Invalid flags"
  end

  test "regex configuration schema includes required fields" do
    regex = Transformations::RegexReplace.new(pattern: "test", replacement: "demo")
    schema = regex.configuration_schema

    assert_includes schema[:required], "pattern"
    assert_includes schema[:required], "replacement"
    assert_equal "string", schema[:properties][:pattern][:type]
    assert_equal "string", schema[:properties][:replacement][:type]
  end

  test "common log parsing transformation" do
    # Transform log timestamps from ISO to readable format
    log_regex = Transformations::RegexReplace.new(
      pattern: '(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})',
      replacement: '\1 \2'
    )

    log_line = "2025-01-07T14:30:45 INFO User logged in"
    result = log_regex.apply(log_line)

    assert_equal "2025-01-07 14:30:45 INFO User logged in", result
  end
end
