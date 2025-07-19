# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransformationLoaderService, type: :service do
  let(:engine) { TransformationEngine.new }
  let(:service) { described_class.new(engine) }

  describe "#initialize" do
    it "initializes with an engine and empty configurations" do
      expect(service.instance_variable_get(:@engine)).to eq(engine)
      expect(service.available_transformations).to be_empty
    end
  end

  describe "#load_all" do
    it "loads built-in transformations and returns the engine" do
      result = service.load_all

      expect(result).to eq(engine)
      expect(engine.available_transformations).to include("base64_encode", "base64_decode")
    end

    it "populates available_transformations with metadata" do
      service.load_all
      transformations = service.available_transformations

      expect(transformations).to be_an(Array)
      expect(transformations.length).to eq(2)

      base64_encode = transformations.find { |t| t[:name] == "base64_encode" }
      expect(base64_encode).to include(
        name: "base64_encode",
        display_name: "Base64 Encode",
        description: "Encode text using Base64 encoding",
        type: "built_in",
        source: "Transformations::Base64Encode"
      )
    end

    context "when transformation loading fails" do
      before do
        allow(Transformations::Base64Encode).to receive(:new).and_raise(StandardError.new("Test error"))
      end

      it "raises TransformationLoaderError" do
        expect { service.load_all }.to raise_error(TransformationLoaderError, /Built-in transformation loading failed/)
      end
    end
  end

  describe "#available_transformations" do
    it "returns empty array initially" do
      expect(service.available_transformations).to be_empty
    end

    it "returns transformation metadata after loading" do
      service.load_all
      transformations = service.available_transformations

      expect(transformations).to all(include(:name, :display_name, :description, :type, :source))
    end
  end

  describe "private methods" do
    describe "#format_display_name" do
      it "converts snake_case to Title Case" do
        result = service.send(:format_display_name, "base64_encode")
        expect(result).to eq("Base64 Encode")
      end

      it "handles single words" do
        result = service.send(:format_display_name, "test")
        expect(result).to eq("Test")
      end
    end

    describe "#load_built_in_transformations" do
      it "registers transformations with the engine" do
        service.send(:load_built_in_transformations)

        expect(engine.find_transformation("base64_encode")).to be_present
        expect(engine.find_transformation("base64_decode")).to be_present
      end

      it "logs successful loading" do
        expect(Rails.logger).to receive(:info).with("Loaded 2 built-in transformations")
        service.send(:load_built_in_transformations)
      end
    end

    describe "#load_yaml_transformations" do
      it "logs that YAML transformations are disabled" do
        expect(Rails.logger).to receive(:info).with("YAML transformations temporarily disabled for initial setup")
        service.send(:load_yaml_transformations)
      end

      it "returns early without loading anything" do
        initial_count = engine.available_transformations.length
        service.send(:load_yaml_transformations)
        expect(engine.available_transformations.length).to eq(initial_count)
      end
    end
  end
end
