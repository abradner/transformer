# frozen_string_literal: true

# Service class for analyzing git changes and providing commit validation
class CommitReviewer
  def initialize
    @git_analyzer = GitAnalyzer.new
    @goal_analyzer = GoalAnalyzer.new
    @code_analyzer = CodeQualityAnalyzer.new
  end

  def analyze_changes
    changes = @git_analyzer.get_worktree_diff

    return ReviewResult.no_changes if changes.empty?

    goal_analysis = @goal_analyzer.check_alignment(changes)
    quality_analysis = @code_analyzer.review_changes(changes)

    ReviewResult.new(
      changes: changes,
      goal_alignment: goal_analysis,
      quality_issues: quality_analysis.issues,
      suggestions: build_suggestions(goal_analysis, quality_analysis)
    )
  end

  def generate_commit_message
    changes = @git_analyzer.get_worktree_diff
    return "No changes to commit" if changes.empty?

    goal_analysis = @goal_analyzer.check_alignment(changes)
    message_generator = CommitMessageGenerator.new(changes, goal_analysis)
    message_generator.generate
  end

  private

  def build_suggestions(goal_analysis, quality_analysis)
    suggestions = []

    suggestions << "⚠️  Changes don't align with current story goals" unless goal_analysis.aligned?
    suggestions.concat(quality_analysis.suggestions) if quality_analysis.has_suggestions?

    suggestions
  end
end
