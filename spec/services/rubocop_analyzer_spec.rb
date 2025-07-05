# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RubocopAnalyzer, type: :service do
  let(:analyzer) { described_class.new }

  describe '#analyze_files' do
    it 'returns empty result for no Ruby files' do
      files = [ 'config/test.yml', 'README.md' ]

      result = analyzer.analyze_files(files)

      expect(result).to be_a(CodeQualityResult)
      expect(result.issues).to be_empty
      expect(result.suggestions).to be_empty
    end

    it 'returns empty result for empty file list' do
      result = analyzer.analyze_files([])

      expect(result).to be_a(CodeQualityResult)
      expect(result.issues).to be_empty
      expect(result.suggestions).to be_empty
    end

    it 'handles RuboCop execution with mocked output' do
      files = [ 'app/models/test.rb' ]

      # Mock the system command execution
      allow(analyzer).to receive(:`).and_return(sample_rubocop_json)
      allow($?).to receive(:success?).and_return(true)
      allow(File).to receive(:exist?).with('app/models/test.rb').and_return(true)

      result = analyzer.analyze_files(files)

      expect(result).to be_a(CodeQualityResult)
      expect(result.issues.first).to include('Style/StringLiterals')
      expect(result.suggestions.first).to include('Consider using consistent string quote style')
    end

    it 'handles RuboCop execution errors gracefully' do
      files = [ 'app/models/test.rb' ]

      # Mock RuboCop execution failure
      allow(analyzer).to receive(:`).and_raise(StandardError, 'Command failed')
      allow(File).to receive(:exist?).with('app/models/test.rb').and_return(true)

      result = analyzer.analyze_files(files)

      expect(result.issues.first).to include('RuboCop analysis failed')
      expect(result.suggestions.first).to include('Try running')
    end
  end

  describe '#parse_rubocop_output' do
    it 'converts RuboCop JSON to quality issues' do
      json_output = sample_rubocop_json

      issues = analyzer.send(:parse_rubocop_output, json_output)

      expect(issues.first).to include('Style/StringLiterals')
      expect(issues.first).to include('app/models/test.rb:5:10')
    end

    it 'handles empty RuboCop output' do
      json_output = '{"files":[]}'

      issues = analyzer.send(:parse_rubocop_output, json_output)

      expect(issues).to be_empty
    end

    it 'handles malformed JSON gracefully' do
      json_output = '{"invalid": json'

      expect {
        analyzer.send(:parse_rubocop_output, json_output)
      }.not_to raise_error
    end
  end

  describe '#generate_suggestions' do
    it 'provides specific suggestions based on issue patterns' do
      issues = [
        'Style/StringLiterals: Use consistent quotes',
        'Layout/LineLength: Line too long',
        'Metrics/MethodLength: Method too long'
      ]

      suggestions = analyzer.send(:generate_suggestions, issues)

      expect(suggestions).to include(a_string_matching(/consistent string quote/))
      expect(suggestions).to include(a_string_matching(/breaking long lines/))
      expect(suggestions).to include(a_string_matching(/extracting complex logic/))
    end

    it 'provides generic suggestion when no specific patterns match' do
      issues = [ 'Some/UnknownCop: Unknown issue' ]

      suggestions = analyzer.send(:generate_suggestions, issues)

      expect(suggestions).to include(a_string_matching(/rubocop -a/))
    end
  end

  private

  def sample_rubocop_json
    {
      "files" => [
        {
          "path" => "app/models/test.rb",
          "offenses" => [
            {
              "severity" => "convention",
              "message" => "Prefer single-quoted strings when you don't need string interpolation or special symbols.",
              "cop_name" => "Style/StringLiterals",
              "corrected" => false,
              "location" => {
                "start_line" => 5,
                "start_column" => 10,
                "last_line" => 5,
                "last_column" => 25
              }
            }
          ]
        }
      ]
    }.to_json
  end
end
