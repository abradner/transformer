# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatabaseTransformationAdapter do
  let(:adapter) { described_class.new }

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

  describe "#create" do
    it "creates a new transformation" do
      transformation = adapter.create(
        name: "test_transform",
        description: "A test transformation",
        version: "1.0.0",
        transformations: sample_transformations
      )

      expect(transformation).to be_a(Domain::TransformationDefinition)
      expect(transformation.name).to eq("test_transform")
      expect(transformation.description).to eq("A test transformation")
      expect(transformation.version).to eq("1.0.0")
      expect(transformation.database_persisted?).to be true
      expect(transformation.transformations).to eq(sample_transformations)
    end

    it "raises validation error for invalid data" do
      expect {
        adapter.create(
          name: "",
          description: "Invalid",
          version: "1.0.0",
          transformations: sample_transformations
        )
      }.to raise_error(DatabaseTransformationAdapter::ValidationError)
    end
  end

  describe "#load_all" do
    before do
      adapter.create(
        name: "transform1",
        description: "First transform",
        version: "1.0.0",
        transformations: sample_transformations
      )

      adapter.create(
        name: "transform2",
        description: "Second transform",
        version: "2.0.0",
        transformations: sample_transformations
      )
    end

    it "loads all transformations" do
      transformations = adapter.load_all

      expect(transformations.size).to eq(2)
      names = transformations.map(&:name)
      expect(names).to include("transform1", "transform2")
    end
  end

  describe "#load_by_name" do
    let!(:transformation) do
      adapter.create(
        name: "named_transform",
        description: "Named transformation",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "loads transformation by name" do
      result = adapter.load_by_name("named_transform")

      expect(result).to be_a(Domain::TransformationDefinition)
      expect(result.name).to eq("named_transform")
    end

    it "returns nil for non-existent transformation" do
      result = adapter.load_by_name("non_existent")
      expect(result).to be_nil
    end
  end

  describe "#update" do
    let!(:transformation) do
      adapter.create(
        name: "update_test",
        description: "Original description",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "updates transformation attributes" do
      updated = adapter.update(transformation.source_id, {
        description: "Updated description",
        version: "1.1.0"
      })

      expect(updated.description).to eq("Updated description")
      expect(updated.version).to eq("1.1.0")
    end

    it "updates transformations array" do
      new_transformations = [
        {
          "type" => "base64_encode",
          "config" => {}
        }
      ]

      updated = adapter.update(transformation.source_id, {
        transformations: new_transformations
      })

      expect(updated.transformations).to eq(new_transformations)
    end
  end

  describe "#delete" do
    let!(:transformation) do
      adapter.create(
        name: "delete_test",
        description: "To be deleted",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "deletes transformation" do
      expect(adapter.delete(transformation.source_id)).to be true
      expect(adapter.load_by_id(transformation.source_id)).to be_nil
    end
  end
end
