# frozen_string_literal: true

namespace :commit do
  desc "Review current git changes against project goals and code quality standards"
  task review: :environment do
    reviewer = CommitReviewer.new
    result = reviewer.analyze_changes

    puts result.summary
    puts "\n" + (result.details.present? ? result.details : "No quality issues or suggestions found.")
    puts "\n" + result.suggestions.join("\n") if result.suggestions.present?
  end

  desc "Generate commit message based on current changes"
  task message: :environment do
    reviewer = CommitReviewer.new
    message = reviewer.generate_commit_message

    puts "Suggested commit message:"
    puts "=" * 50
    puts message
    puts "=" * 50
  end
end
