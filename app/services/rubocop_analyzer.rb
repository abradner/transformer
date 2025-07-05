# frozen_string_literal: true

require "open3"
require "shellwords"

# Service to integrate RuboCop analysis with our commit validation system
class RubocopAnalyzer
  def initialize
    @rubocop_executable = Rails.root.join("bin", "rubocop")
  end

  def analyze_files(files)
    ruby_files = filter_ruby_files(files)
    return CodeQualityResult.new(issues: [], suggestions: []) if ruby_files.empty?

    begin
      json_output = run_rubocop(ruby_files)
      issues = parse_rubocop_output(json_output)
      suggestions = generate_suggestions(issues)

      CodeQualityResult.new(issues: issues, suggestions: suggestions)
    rescue StandardError => e
      CodeQualityResult.new(
        issues: [ "❌ RuboCop analysis failed: #{e.message}" ],
        suggestions: [ "💡 Try running `bundle exec rubocop` manually to debug" ]
      )
    end
  end

  private

  def filter_ruby_files(files)
    files.select { |file| file.end_with?(".rb") && File.exist?(file) }
  end

  def run_rubocop(files)
    escaped_files = files.map { |file| Shellwords.escape(file) }
    cmd = [ @rubocop_executable.to_s, "--format", "json", "--force-exclusion" ] + escaped_files

    stdout, stderr, status = Open3.capture3(cmd.join(" "))

    # RuboCop exits 1 on success with offenses, 0 on success with no offenses.
    # It exits > 1 on error.
    raise "RuboCop execution failed: #{stderr.strip}" if !status.success? && status.exitstatus > 1

    stdout
  end

  def parse_rubocop_output(json_output)
    return [] if json_output.blank?

    begin
      data = JSON.parse(json_output)
    rescue JSON::ParserError
      # Return empty array if JSON is malformed
      return []
    end

    issues = []

    data["files"]&.each do |file|
      file_path = file["path"]

      file["offenses"]&.each do |offense|
        severity_icon = severity_to_icon(offense["severity"])
        location = "#{file_path}:#{offense['location']['start_line']}:#{offense['location']['start_column']}"

        issues << "#{severity_icon} #{offense['cop_name']}: #{offense['message']} (#{location})"
      end
    end

    issues
  end

  def severity_to_icon(severity)
    case severity
    when "error", "fatal"
      "❌"
    when "warning"
      "⚠️"
    when "convention", "refactor"
      "💡"
    else
      "📝"
    end
  end

  def generate_suggestions(issues)
    suggestions = []

    # Analyze patterns in issues to provide actionable suggestions
    if issues.any? { |issue| issue.include?("StringLiterals") }
      suggestions << "💡 Consider using consistent string quote style (see Style/StringLiterals)"
    end

    if issues.any? { |issue| issue.include?("LineLength") }
      suggestions << "💡 Consider breaking long lines or extracting methods (see Layout/LineLength)"
    end

    if issues.any? { |issue| issue.include?("MethodLength") }
      suggestions << "💡 Consider extracting complex logic to smaller methods (see Metrics/MethodLength)"
    end

    if issues.any? { |issue| issue.include?("ClassLength") }
      suggestions << "💡 Consider breaking large classes into smaller, focused classes (see Metrics/ClassLength)"
    end

    # Add general suggestion if we have issues but no specific suggestions
    if suggestions.empty? && issues.any?
      suggestions << "💡 Run `bundle exec rubocop -a` to auto-fix some issues"
    end

    suggestions
  end

  def last_process_status
    $?
  end
end
