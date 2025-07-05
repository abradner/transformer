# frozen_string_literal: true

# Model for storing goal alignment analysis results
class GoalAlignment
  attr_reader :aligned, :reason, :story_context

  def initialize(aligned:, reason:, story_context: {})
    @aligned = aligned
    @reason = reason
    @story_context = story_context
  end

  def aligned?
    @aligned
  end

  def self.no_story_found
    new(aligned: false, reason: "No 'In Progress' story found in goals.md.")
  end

  def self.no_changes
    new(aligned: true, reason: "No changes to analyze.")
  end
end
