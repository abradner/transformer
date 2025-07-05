# frozen_string_literal: true

# Generates conventional commit messages based on git changes and goal analysis
class CommitMessageGenerator
  def initialize(changes, goal_analysis)
    @changes = changes
    @goal_analysis = goal_analysis
  end

  def generate
    type = determine_commit_type
    scope = determine_scope
    description = generate_description
    body = generate_body

    message = "#{type}"
    message += "(#{scope})" if scope
    message += ": #{description}"
    message += "\n\n#{body}" if body.present?

    message
  end

  private

  def determine_commit_type
    files = @changes.map(&:file).uniq

    return 'feat' if files.any? { |f| f.start_with?('app/') && !f.include?('spec/') }
    return 'test' if files.all? { |f| f.include?('spec/') || f.include?('test/') }
    return 'docs' if files.all? { |f| f.end_with?('.md') || f.include?('docs/') }
    return 'chore' if files.any? { |f| f.start_with?('lib/tasks/') }
    return 'refactor' if has_only_modifications?
    return 'fix' if seems_like_bug_fix?

    'feat' # default
  end

  def determine_scope
    files = @changes.map(&:file).uniq

    return 'validation' if files.any? { |f| f.include?('commit') || f.include?('validation') }
    return 'yaml' if files.any? { |f| f.include?('yaml') || f.include?('transformations') }
    return 'engine' if files.any? { |f| f.include?('transformation_engine') }
    return 'tasks' if files.any? { |f| f.start_with?('lib/tasks/') }

    nil
  end

  def generate_description
    return extract_story_description if @goal_analysis.current_story

    files = @changes.map(&:file).uniq

    if files.length == 1
      file = files.first
      return "add #{File.basename(file, File.extname(file)).humanize.downcase}"
    end

    primary_change = determine_primary_change_type
    "#{primary_change} #{files.length} files"
  end

  def generate_body
    lines = []

    if @goal_analysis.current_story
      lines << "Story: #{@goal_analysis.current_story}"
    end

    # Group changes by type
    additions = @changes.select { |c| c.type == :addition }.map(&:file).uniq
    deletions = @changes.select { |c| c.type == :deletion }.map(&:file).uniq

    if additions.any?
      lines << ""
      lines << "Added:"
      additions.each { |file| lines << "- #{file}" }
    end

    if deletions.any?
      lines << ""
      lines << "Removed:"
      deletions.each { |file| lines << "- #{file}" }
    end

    lines.join("\n")
  end

  def extract_story_description
    story = @goal_analysis.current_story
    return "update project goals" unless story

    # Extract the main purpose from story title
    if story.include?('Commit Validation')
      "add commit validation and review tooling"
    elsif story.include?('YAML')
      "enhance YAML transformation system"
    elsif story.include?('Testing')
      "improve testing infrastructure"
    else
      story.split(':').last&.strip&.downcase || "update codebase"
    end
  end

  def has_only_modifications?
    # Check if changes are primarily modifications rather than new files
    files = @changes.map(&:file).uniq
    modifications = files.count { |f| File.exist?(Rails.root.join(f)) }
    modifications > files.length / 2
  end

  def seems_like_bug_fix?
    content = @changes.map(&:content).join(' ')
    fix_keywords = ['fix', 'bug', 'error', 'issue', 'correct', 'resolve']
    fix_keywords.any? { |keyword| content.downcase.include?(keyword) }
  end

  def determine_primary_change_type
    additions = @changes.count { |c| c.type == :addition }
    deletions = @changes.count { |c| c.type == :deletion }

    if additions > deletions
      'add'
    elsif deletions > additions
      'remove'
    else
      'update'
    end
  end
end
