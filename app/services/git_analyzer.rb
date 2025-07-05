# frozen_string_literal: true

require "open3"

# Analyzes git worktree changes including staged and unstaged modifications
class GitAnalyzer
  def get_worktree_diff
    # Get both staged and unstaged changes
    staged_diff, staged_error, staged_status = Open3.capture3("git diff --cached HEAD")
    raise "Git command failed: #{staged_error.strip}" unless staged_status.success?

    unstaged_diff, unstaged_error, unstaged_status = Open3.capture3("git diff HEAD")
    raise "Git command failed: #{unstaged_error.strip}" unless unstaged_status.success?

    combined_diff = [ staged_diff, unstaged_diff ].reject(&:empty?).join("\n")

    return [] if combined_diff.empty?

    parse_diff(combined_diff)
  end

  def get_changed_files
    # Get list of all changed files (staged and unstaged)
    unstaged_files_str, unstaged_error, unstaged_status = Open3.capture3("git diff --name-only HEAD")
    raise "Git command failed: #{unstaged_error.strip}" unless unstaged_status.success?

    staged_files_str, staged_error, staged_status = Open3.capture3("git diff --cached --name-only HEAD")
    raise "Git command failed: #{staged_error.strip}" unless staged_status.success?

    files = unstaged_files_str.split("\n")
    files += staged_files_str.split("\n")
    files.uniq
  end

  private

  def parse_diff(diff_text)
    changes = []
    current_file = nil

    diff_text.split("\n").each do |line|
      if line.start_with?("diff --git")
        # Extract filename from: diff --git a/file.rb b/file.rb
        current_file = line.split(" ").last.sub("b/", "")
      elsif line.start_with?("+") && !line.start_with?("+++")
        # Addition
        changes << GitChange.new(
          file: current_file,
          type: :addition,
          content: line[1..-1],
          line: line
        )
      elsif line.start_with?("-") && !line.start_with?("---")
        # Deletion
        changes << GitChange.new(
          file: current_file,
          type: :deletion,
          content: line[1..-1],
          line: line
        )
      end
    end

    changes
  end
end

# Represents a single change in the git diff
class GitChange
  attr_reader :file, :type, :content, :line

  def initialize(file:, type:, content:, line:)
    @file = file
    @type = type
    @content = content
    @line = line
  end

  def ruby_file?
    file&.end_with?(".rb")
  end

  def test_file?
    file&.include?("spec/") || file&.end_with?("_test.rb")
  end

  def yaml_file?
    file&.end_with?(".yml", ".yaml")
  end

  def config_file?
    file&.start_with?("config/")
  end
end
