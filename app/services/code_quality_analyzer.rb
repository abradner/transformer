# frozen_string_literal: true

# Analyzes code changes for quality issues using RuboCop and custom checks
class CodeQualityAnalyzer
  def initialize
    @rubocop_analyzer = RubocopAnalyzer.new
  end

  def review_changes(changes)
    ruby_files = extract_changed_ruby_files(changes)

    # Use RuboCop for Ruby file analysis
    rubocop_result = @rubocop_analyzer.analyze_files(ruby_files)

    # Keep custom analysis for non-Ruby files and Zeitwerk-specific checks
    custom_issues = analyze_custom_patterns(changes)
    custom_suggestions = generate_custom_suggestions(changes)

    # Combine RuboCop and custom analysis
    all_issues = rubocop_result.issues + custom_issues
    all_suggestions = rubocop_result.suggestions + custom_suggestions

    CodeQualityResult.new(issues: all_issues, suggestions: all_suggestions)
  end

  private

  def extract_changed_ruby_files(changes)
    changes.select(&:ruby_file?).map(&:file).uniq.compact
  end

  def analyze_custom_patterns(changes)
    issues = []

    # Zeitwerk compliance checks (not covered by RuboCop by default)
    issues.concat(analyze_zeitwerk_compliance(changes.select(&:ruby_file?)))

    # YAML file analysis
    issues.concat(analyze_yaml_structure(changes.select(&:yaml_file?)))

    issues
  end

  def analyze_zeitwerk_compliance(ruby_changes)
    issues = []

    ruby_changes.each do |change|
      next unless change.type == :addition && change.content.include?("class ")

      file = change.file
      content = change.content

      # Extract class name from content
      class_match = content.match(/class\s+(\w+)/)
      next unless class_match

      class_name = class_match[1]
      expected_file = class_name.underscore + ".rb"
      actual_file = File.basename(file)

      unless actual_file == expected_file
        issues << "❌ Zeitwerk violation: #{class_name} should be in #{expected_file}, not #{actual_file}"
      end

      # Check for namespace consistency
      if file.include?("/")
        namespace_path = File.dirname(file).split("/").map(&:camelize).join("::")
        unless content.include?("module #{namespace_path}")
          issues << "❌ Missing namespace module #{namespace_path} in #{file}"
        end
      end
    end

    issues
  end

  def analyze_yaml_structure(yaml_changes)
    issues = []

    yaml_changes.each do |change|
      next unless change.type == :addition

      content = change.content

      # Check for YAML best practices
      issues << "⚠️  Hard tabs in YAML file #{change.file}" if content.include?("\t")
      issues << "⚠️  Very long line in YAML #{change.file}" if content.length > 120
    end

    issues
  end

  def generate_custom_suggestions(changes)
    suggestions = []

    ruby_files = changes.select(&:ruby_file?).map(&:file).uniq
    test_files = changes.select(&:test_file?).map(&:file).uniq

    app_files = ruby_files.select { |f| f.start_with?("app/") }

    if app_files.any? && test_files.empty?
      suggestions << "🧪 Consider adding tests for new application code"
    end

    if changes.any?(&:yaml_file?) && !test_files.any? { |f| f.include?("yaml") }
      suggestions << "🧪 Consider adding tests for YAML configuration changes"
    end

    suggestions
  end
end
