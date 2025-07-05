# frozen_string_literal: true

# Represents the result of commit review analysis
class ReviewResult
  attr_reader :changes, :goal_alignment, :quality_issues, :suggestions

  def initialize(changes:, goal_alignment:, quality_issues:, suggestions:)
    @changes = changes
    @goal_alignment = goal_alignment
    @quality_issues = quality_issues
    @suggestions = suggestions
  end

  def summary
    lines = []
    lines << "📊 Commit Review Summary"
    lines << "=" * 40

    if @changes.any?
      files = @changes.map(&:file).uniq.compact
      lines << "📁 Files changed: #{files.length}"
      lines << "📝 Total changes: #{@changes.length}"

      if @goal_alignment.current_story
        lines << "🎯 Current story: #{@goal_alignment.current_story}"
        lines << (@goal_alignment.aligned? ? "✅ Changes align with story goals" : "⚠️  Changes may not align with current story")
      else
        lines << "⚠️  No current story found in goals.md"
      end

      if @quality_issues.any?
        lines << "❌ Quality issues found: #{@quality_issues.length}"
      else
        lines << "✅ No quality issues detected"
      end

      if @suggestions.any?
        lines << "💡 Suggestions available: #{@suggestions.length}"
      end
    end

    lines.join("\n")
  end

  def details
    return nil unless @quality_issues.any? || @suggestions.any?

    lines = []

    if @quality_issues.any?
      lines << "🔍 Quality Issues:"
      @quality_issues.each { |issue| lines << "  #{issue}" }
    end

    if @suggestions.any?
      lines << ""
      lines << "💡 Suggestions:"
      @suggestions.each { |suggestion| lines << "  #{suggestion}" }
    end

    lines.join("\n")
  end

  def self.no_changes
    new(
      changes: [],
      goal_alignment: GoalAlignment.no_story_found,
      quality_issues: [],
      suggestions: []
    )
  end
end
