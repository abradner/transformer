# frozen_string_literal: true

require "rails_helper"
require "transformer/validator"

RSpec.describe Transformer::Validator do
  describe ".validate_all" do
    # This method is complex to test in isolation as it interacts with the file system and Rails.
    # Its behavior is indirectly tested via the `transformer:validate` rake task spec.
    # We will focus on testing the `validate_file` method directly.
  end

  describe ".validate_file" do
    let(:schema_path) { Rails.root.join("docs", "schemas", "transformation_schema.json") }
    let(:schema_content) { File.read(schema_path) }
    let(:schemer) { JSONSchemer.schema(Pathname.new(schema_path)) }

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(schema_path.to_s).and_return(schema_content)
    end

    it "returns an empty array for a valid file" do
      valid_yaml = {
        "name" => "valid_transform",
        "description" => "A valid transformation",
        "version" => "1.0",
        "transformations" => [
          {
            "type" => "regex_replace",
            "config" => { "pattern" => "a", "replacement" => "b" }
          }
        ]
      }.to_yaml
      allow(File).to receive(:read).with("/path/to/valid.yml").and_return(valid_yaml)

      expect(described_class.validate_file("/path/to/valid.yml", schemer)).to be_empty
    end

    it "returns a syntax error for an invalid YAML file" do
      invalid_yaml = "name: 'invalid\ndescription: 'bad syntax'"
      allow(File).to receive(:read).with("/path/to/invalid_syntax.yml").and_return(invalid_yaml)

      errors = described_class.validate_file("/path/to/invalid_syntax.yml", schemer)
      expect(errors.first).to include("ERROR: Invalid YAML syntax in /path/to/invalid_syntax.yml")
    end

    it "returns a schema error for a file with an invalid schema" do
      invalid_schema_yaml = {
        "name" => "invalid_schema",
        "description" => "Missing version and transformations"
      }.to_yaml
      allow(File).to receive(:read).with("/path/to/invalid_schema.yml").and_return(invalid_schema_yaml)

      errors = described_class.validate_file("/path/to/invalid_schema.yml", schemer)
      expect(errors.first).to eq("ERROR: Schema validation failed for /path/to/invalid_schema.yml:")
      expect(errors.last).to include("missing required properties: version, transformations")
    end
  end
end
