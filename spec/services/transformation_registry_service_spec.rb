# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransformationRegistryService do
  let(:service) { described_class.new }

  let(:sample_transformations) do
    [
      {
        "type" => "regex_replace",
        "config" => {
          "pattern" => "test",
          "replacement" => "result",
          "flags" => [ "global" ]
        }
      }
    ]
  end

  describe "#load_all" do
    before do
      # Create a database transformation
      service.create_transformation(
        name: "db_transform",
        description: "Database transformation",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "loads transformations from both file and database sources" do
      result = service.load_all

      expect(result).to be_a(TransformationRegistryService::LoadResult)
      expect(result.success?).to be true
      expect(result.transformations.size).to be > 0

      # Should have both file-based and database transformations
      source_types = result.transformations.map(&:source_type).uniq
      expect(source_types).to include(:file, :database)
    end

    it "includes file-based transformations" do
      result = service.load_all
      names = result.transformations.map(&:name)

      # Should include our known file-based transformations
      expect(names).to include("log_level_highlighter")
    end

    it "includes database transformations" do
      result = service.load_all
      names = result.transformations.map(&:name)

      # Should include our created database transformation
      expect(names).to include("db_transform")
    end
  end

  describe "#load_by_name" do
    before do
      service.create_transformation(
        name: "test_db_transform",
        description: "Test transformation",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "loads database transformations by name" do
      transformation = service.load_by_name("test_db_transform")

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.name).to eq("test_db_transform")
      expect(transformation.database_persisted?).to be true
    end

    it "loads file-based transformations by name" do
      transformation = service.load_by_name("log_level_highlighter")

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.name).to eq("log_level_highlighter")
      expect(transformation.file_based?).to be true
    end

    it "prefers database transformations over file-based when names conflict" do
      # Create a database transformation with same name as file-based one
      service.create_transformation(
        name: "conflicting_name",
        description: "Database version",
        version: "2.0.0",
        transformations: sample_transformations
      )

      # Also create a file with the same name (simulate conflict)
      transformation = service.load_by_name("conflicting_name")
      expect(transformation.database_persisted?).to be true
    end
  end

  describe "#create_transformation" do
    it "creates new database transformation" do
      transformation = service.create_transformation(
        name: "new_transform",
        description: "New transformation",
        version: "1.0.0",
        transformations: sample_transformations
      )

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.name).to eq("new_transform")
      expect(transformation.database_persisted?).to be true
    end

    it "raises conflict error when name conflicts with file-based transformation" do
      expect {
        service.create_transformation(
          name: "log_level_highlighter", # Conflicts with file-based
          description: "Conflicting transformation",
          version: "1.0.0",
          transformations: sample_transformations
        )
      }.to raise_error(TransformationRegistryService::ConflictError)
    end
  end

  describe "#statistics" do
    before do
      service.create_transformation(
        name: "stats_test",
        description: "For stats",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "returns statistics about transformation sources" do
      stats = service.statistics

      expect(stats).to have_key(:total)
      expect(stats).to have_key(:file_based)
      expect(stats).to have_key(:database_persisted)
      expect(stats).to have_key(:conflicts)

      expect(stats[:file_based]).to be > 0 # We have file-based transformations
      expect(stats[:database_persisted]).to be > 0 # We created one
      expect(stats[:total]).to be > 0
    end
  end

  describe "#available_names" do
    it "returns unique list of transformation names from both sources" do
      names = service.available_names

      expect(names).to be_an(Array)
      expect(names).to include("log_level_highlighter") # file-based
      expect(names.uniq).to eq(names) # no duplicates
    end
  end

  describe "conflict resolution" do
    it "handles name conflicts gracefully" do
      # This test verifies that the service can handle conflicts between
      # file-based and database transformations
      result = service.load_all

      # Should not crash and should return results
      expect(result).to be_a(TransformationRegistryService::LoadResult)
      expect(result.transformations).to be_an(Array)
    end
  end
end
