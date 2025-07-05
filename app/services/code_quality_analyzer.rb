# frozen_string_literal: true

# Analyzes code changes for quality issues and Rails best practices
class CodeQualityAnalyzer
  def review_changes(changes)
    issues = []
    suggestions = []

    ruby_changes = changes.select(&:ruby_file?)
    yaml_changes = changes.select(&:yaml_file?)

    issues.concat(analyze_ruby_patterns(ruby_changes))
    issues.concat(analyze_zeitwerk_compliance(ruby_changes))
    issues.concat(analyze_yaml_structure(yaml_changes))

    suggestions.concat(generate_refactoring_suggestions(ruby_changes))
    suggestions.concat(generate_testing_suggestions(changes))

    CodeQualityResult.new(issues: issues, suggestions: suggestions)
  end

  private

  def analyze_ruby_patterns(ruby_changes)
    issues = []

    ruby_changes.each do |change|
      next unless change.type == :addition

      content = change.content

      # Check for common anti-patterns
      issues << "❌ Long method detected in #{change.file}" if content.length > 120
      issues << "❌ TODO comment found in #{change.file}" if content.include?('TODO') || content.include?('FIXME')
      issues << "❌ Hardcoded string in #{change.file}" if content.match?(/["'][^"']{50,}["']/)
      issues << "❌ Multiple responsibilities in class #{change.file}" if content.include?('def ') && content.scan(/def \w+/).length > 10
    end

    issues
  end

  def analyze_zeitwerk_compliance(ruby_changes)
    issues = []

    ruby_changes.each do |change|
      next unless change.type == :addition && change.content.include?('class ')

      file = change.file
      content = change.content

      # Extract class name from content
      class_match = content.match(/class\s+(\w+)/)
      next unless class_match

      class_name = class_match[1]
      expected_file = class_name.underscore + '.rb'
      actual_file = File.basename(file)

      unless actual_file == expected_file
        issues << "❌ Zeitwerk violation: #{class_name} should be in #{expected_file}, not #{actual_file}"
      end

      # Check for namespace consistency
      if file.include?('/')
        namespace_path = File.dirname(file).split('/').map(&:camelize).join('::')
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

  def generate_refactoring_suggestions(ruby_changes)
    suggestions = []

    # Look for potential service extraction opportunities
    model_changes = ruby_changes.select { |c| c.file.include?('app/models/') }
    if model_changes.any? { |c| c.content.include?('def ') && c.content.length > 50 }
      suggestions << "💡 Consider extracting complex logic to service objects"
    end

    # Look for repeated patterns
    added_content = ruby_changes.select { |c| c.type == :addition }.map(&:content)
    if added_content.join.scan(/\.new\(/).length > 5
      suggestions << "💡 Consider using factory pattern for object creation"
    end

    suggestions
  end

  def generate_testing_suggestions(changes)
    suggestions = []

    ruby_files = changes.select(&:ruby_file?).map(&:file).uniq
    test_files = changes.select(&:test_file?).map(&:file).uniq

    app_files = ruby_files.select { |f| f.start_with?('app/') }

    if app_files.any? && test_files.empty?
      suggestions << "🧪 Consider adding tests for new application code"
    end

    if changes.any?(&:yaml_file?) && !test_files.any? { |f| f.include?('yaml') }
      suggestions << "🧪 Consider adding tests for YAML configuration changes"
    end

    suggestions
  end
end

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
