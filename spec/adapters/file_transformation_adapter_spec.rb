# frozen_string_literal: true

require "rails_helper"

RSpec.describe FileTransformationAdapter do
  let(:adapter) { described_class.new }

  describe "#load_all" do
    it "loads all YAML transformations from config directory" do
      transformations = adapter.load_all

      expect(transformations).to be_an(Array)
      expect(transformations.size).to be > 0

      # Check that we loaded the known transformations
      names = transformations.map(&:name)
      expect(names).to include("log_level_highlighter", "log_timestamp_normalizer", "k8s_secret_decoder")
    end

    it "returns domain transformation objects" do
      transformations = adapter.load_all
      transformation = transformations.first

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.file_based?).to be true
      expect(transformation.source_type).to eq(:file)
      expect(transformation.name).to be_present
      expect(transformation.description).to be_present
      expect(transformation.version).to be_present
      expect(transformation.transformations).to be_an(Array)
    end
  end

  describe "#load_by_name" do
    it "loads a specific transformation by name" do
      transformation = adapter.load_by_name("log_level_highlighter")

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.name).to eq("log_level_highlighter")
      expect(transformation.description).to include("visual emphasis")
      expect(transformation.transformations).to be_an(Array)
      expect(transformation.transformations.size).to be > 0
    end

    it "returns nil for non-existent transformation" do
      transformation = adapter.load_by_name("non_existent")
      expect(transformation).to be_nil
    end
  end

  describe "#exists?" do
    it "returns true for existing transformations" do
      expect(adapter.exists?("log_level_highlighter")).to be true
    end

    it "returns false for non-existent transformations" do
      expect(adapter.exists?("non_existent")).to be false
    end
  end

  describe "#available_names" do
    it "returns list of available transformation names" do
      names = adapter.available_names

      expect(names).to be_an(Array)
      expect(names).to include("log_level_highlighter", "log_timestamp_normalizer", "k8s_secret_decoder")
    end
  end

  describe "YAML structure validation" do
    it "validates transformation structure from actual files" do
      transformation = adapter.load_by_name("log_level_highlighter")

      # Should have required fields
      expect(transformation.name).to eq("log_level_highlighter")
      expect(transformation.transformations).to be_an(Array)

      # Each transformation should have a type
      transformation.transformations.each do |t|
        expect(t).to have_key("type")
        expect(t["type"]).to be_present
      end
    end
  end
end
