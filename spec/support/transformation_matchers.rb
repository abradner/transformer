# frozen_string_literal: true

# Custom RSpec matchers for the Transformer application

RSpec::Matchers.define :be_a_valid_transformation do
  match do |transformation|
    transformation.respond_to?(:apply) &&
      transformation.respond_to?(:name) &&
      transformation.respond_to?(:description)
  end

  failure_message do |transformation|
    "expected #{transformation} to be a valid transformation with apply, name, and description methods"
  end
end

RSpec::Matchers.define :transform_string do |input|
  match do |transformation|
    @result = transformation.apply(input)
    @result != input && @result.is_a?(String)
  end

  chain :to do |expected_output|
    @expected = expected_output
  end

  match_when_negated do |transformation|
    @result = transformation.apply(input)
    @expected ? @result != @expected : @result == input
  end

  failure_message do |transformation|
    if @expected
      "expected transformation to convert #{input.inspect} to #{@expected.inspect}, but got #{@result.inspect}"
    else
      "expected transformation to change #{input.inspect}, but it remained unchanged"
    end
  end
end
