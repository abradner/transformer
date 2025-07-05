# frozen_string_literal: true

# Analyzes changes against current project goals and stories
class GoalAnalyzer
  GOALS_FILE = Rails.root.join('goals.md')

  def check_alignment(changes)
    current_story = extract_current_story
    return GoalAlignment.no_story_found unless current_story

    file_patterns = analyze_file_patterns(changes)
    story_context = extract_story_context(current_story)

    aligned = check_files_align_with_story(file_patterns, story_context)

    GoalAlignment.new(
      current_story: current_story,
      aligned: aligned,
      context: story_context,
      file_patterns: file_patterns
    )
  end

  private

  def extract_current_story
    return nil unless File.exist?(GOALS_FILE)

    content = File.read(GOALS_FILE)

    # Find the most recent "In Progress" story
    current_match = content.match(/### (Story \d+\.\d+: .+?)\n\*\*Status\*\*: 🔄 In Progress/m)
    current_match&.captures&.first
  end

  def extract_story_context(story_title)
    content = File.read(GOALS_FILE)

    # Extract the section for this story
    story_section = content[/#{Regexp.escape(story_title)}.+?(?=###|\z)/m]
    return {} unless story_section

    {
      keywords: extract_keywords(story_section),
      technologies: extract_technologies(story_section),
      file_areas: extract_file_areas(story_section)
    }
  end

  def extract_keywords(section)
    # Extract key terms from the story description
    keywords = []
    keywords += section.scan(/\*\*([^*]+)\*\*/).flatten
    keywords += section.scan(/`([^`]+)`/).flatten
    keywords.map(&:downcase).uniq
  end

  def extract_technologies(section)
    techs = []
    techs << 'rake' if section.include?('rake')
    techs << 'git' if section.include?('git')
    techs << 'rspec' if section.include?('RSpec') || section.include?('test')
    techs << 'yaml' if section.include?('YAML') || section.include?('yml')
    techs
  end

  def extract_file_areas(section)
    areas = []
    areas << 'lib/tasks' if section.include?('rake')
    areas << 'spec' if section.include?('test') || section.include?('RSpec')
    areas << 'app/services' if section.include?('service') || section.include?('analysis')
    areas
  end

  def analyze_file_patterns(changes)
    files = changes.map(&:file).uniq.compact

    {
      directories: files.map { |f| File.dirname(f) }.uniq,
      extensions: files.map { |f| File.extname(f) }.uniq,
      names: files.map { |f| File.basename(f, File.extname(f)) }
    }
  end

  def check_files_align_with_story(file_patterns, story_context)
    # Check if changed files align with story context
    return true if story_context[:file_areas].empty?

    changed_areas = file_patterns[:directories]
    expected_areas = story_context[:file_areas]

    # At least some changed files should be in expected areas
    (changed_areas & expected_areas).any?
  end
end

# Represents the alignment between changes and project goals
class GoalAlignment
  attr_reader :current_story, :aligned, :context, :file_patterns

  def initialize(current_story:, aligned:, context:, file_patterns:)
    @current_story = current_story
    @aligned = aligned
    @context = context
    @file_patterns = file_patterns
  end

  def aligned?
    @aligned
  end

  def self.no_story_found
    new(
      current_story: nil,
      aligned: false,
      context: {},
      file_patterns: {}
    )
  end
end
