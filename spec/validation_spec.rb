# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Testing Framework Validation', type: :model do
  describe 'RSpec configuration' do
    it 'loads Rails environment correctly' do
      expect(Rails.env).to eq('test')
      expect(Rails.application).to be_present
    end

    it 'includes FactoryBot syntax' do
      expect(self.class.included_modules).to include(FactoryBot::Syntax::Methods)
    end

    it 'includes custom transformation matchers' do
      # Test our custom matcher exists
      transformation = double('transformation')
      allow(transformation).to receive(:apply).and_return('test')
      allow(transformation).to receive(:name).and_return('test transformer')
      allow(transformation).to receive(:description).and_return('test description')

      expect(transformation).to be_a_valid_transformation
    end
  end

  describe 'Database connectivity' do
    it 'connects to test database' do
      expect(ActiveRecord::Base.connection).to be_active
    end

    it 'uses transactional fixtures' do
      expect(RSpec.configuration.use_transactional_fixtures).to be true
    end
  end
end
