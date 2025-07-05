# frozen_string_literal: true

# Result of code quality analysis
class CodeQualityResult
  attr_reader :issues, :suggestions

  def initialize(issues:, suggestions:)
    @issues = issues
    @suggestions = suggestions
  end

  def has_issues?
    @issues.any?
  end

  def has_suggestions?
    @suggestions.any?
  end
end
