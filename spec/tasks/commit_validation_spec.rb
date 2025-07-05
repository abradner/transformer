# frozen_string_literal: true

require 'rails_helper'
require 'rake'

Rails.application.load_tasks

RSpec.describe 'Commit Validation Rake Tasks', type: :task do
  before do
    Rake::Task['commit:review'].reenable
    Rake::Task['commit:message'].reenable
  end

  describe 'rake commit:review' do
    it 'loads the task without errors' do
      expect(Rake::Task['commit:review']).to be_present
    end

    it 'executes without errors when CommitReviewer is available' do
      allow(CommitReviewer).to receive(:new).and_return(
        double('reviewer', analyze_changes: ReviewResult.no_changes)
      )

      expect { Rake::Task['commit:review'].invoke }.not_to raise_error
    end
  end

  describe 'rake commit:message' do
    it 'loads the task without errors' do
      expect(Rake::Task['commit:message']).to be_present
    end

    it 'executes without errors when CommitReviewer is available' do
      allow(CommitReviewer).to receive(:new).and_return(
        double('reviewer', generate_commit_message: 'feat: add new feature')
      )

      expect { Rake::Task['commit:message'].invoke }.not_to raise_error
    end
  end
end
