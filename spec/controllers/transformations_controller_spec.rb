# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransformationsController, type: :controller do
  before do
    # Mock transformation engine and loader
    allow_any_instance_of(TransformationLoaderService).to receive(:load_all)

    # Mock transformation engine for preview functionality
    allow_any_instance_of(TransformationEngine).to receive(:validate_input) do |engine, transformation_name, input|
      case transformation_name
      when "base64_encode", "base64_decode"
        double(valid?: true, errors: [])
      when "nonexistent"
        double(valid?: false, errors: [ "Transformation 'nonexistent' not found" ])
      else
        double(valid?: true, errors: [])
      end
    end

    allow_any_instance_of(TransformationEngine).to receive(:apply) do |engine, transformation_name, input|
      case transformation_name
      when "base64_encode"
        Base64.strict_encode64(input)
      when "base64_decode"
        if input.match?(/^[A-Za-z0-9+\/]*={0,2}$/)
          Base64.decode64(input)
        else
          raise StandardError, "Input does not appear to be valid Base64"
        end
      else
        "transformed: #{input}"
      end
    end

    # Mock the file adapter to return predictable transformations
    mock_file_transformations = [
      Domain::TransformationDefinition.new(
        name: "base64_encode",
        description: "Encode text using Base64 encoding",
        version: "1.0.0",
        transformations: [ { "type" => "base64_encode" } ],
        source_type: :file,
        source_id: "/mock/path/base64_encode.yml"
      ),
      Domain::TransformationDefinition.new(
        name: "base64_decode",
        description: "Decode Base64 encoded text",
        version: "1.0.0",
        transformations: [ { "type" => "base64_decode" } ],
        source_type: :file,
        source_id: "/mock/path/base64_decode.yml"
      )
    ]

    allow_any_instance_of(FileTransformationAdapter).to receive(:load_all).and_return(mock_file_transformations)
    allow_any_instance_of(FileTransformationAdapter).to receive(:exists?).and_return(false)
    allow_any_instance_of(FileTransformationAdapter).to receive(:available_names).and_return([ "base64_encode", "base64_decode" ])
  end

  describe "GET #index" do
    it "renders the transformation interface" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it "initializes transformation engine" do
      get :index
      expect(assigns(:engine)).to be_a(TransformationEngine)
      expect(assigns(:loader)).to be_a(TransformationLoaderService)
    end
  end

  describe "GET #available" do
    it "returns available transformations as JSON" do
      get :available

      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")

      json_response = JSON.parse(response.body)
      expect(json_response).to have_key("transformations")
      expect(json_response["transformations"]).to be_an(Array)
    end

    it "includes file-based transformations" do
      get :available

      json_response = JSON.parse(response.body)
      transformations = json_response["transformations"]

      expect(transformations.length).to eq(2) # We have 2 mocked transformations

      # Check for our mocked transformations
      names = transformations.map { |t| t["name"] }
      expect(names).to include("base64_encode", "base64_decode")

      # Verify they're marked as file-based
      base64_encode = transformations.find { |t| t["name"] == "base64_encode" }
      expect(base64_encode).to include(
        "name" => "base64_encode",
        "source_type" => "file",
        "description" => "Encode text using Base64 encoding"
      )
    end

    context "when transformation loading fails" do
      before do
        allow_any_instance_of(TransformationLoaderService).to receive(:load_all).and_raise(TransformationLoaderError.new("Test error"))
      end

      it "gracefully degrades but still returns file-based transformations" do
        expect(Rails.logger).to receive(:error).with(/Failed to initialize transformation engine/)

        get :available

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        # Mocked transformations should still be available even if engine fails
        expect(json_response["transformations"]).not_to be_empty
        expect(json_response["statistics"]).to have_key("file_based")

        # Should still return our mocked transformations
        names = json_response["transformations"].map { |t| t["name"] }
        expect(names).to include("base64_encode", "base64_decode")
      end
    end
  end

  describe "POST #preview" do
    context "with valid parameters" do
      let(:valid_params) { { name: "base64_encode", input: "Hello World!" } }

      it "returns successful transformation result" do
        post :preview, params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/json")

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => true,
          "result" => "SGVsbG8gV29ybGQh"
        )
      end

      it "handles base64 decode transformation" do
        post :preview, params: { name: "base64_decode", input: "SGVsbG8gV29ybGQh" }

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => true,
          "result" => "Hello World!"
        )
      end
    end

    context "with invalid parameters" do
      it "returns empty result for missing input" do
        post :preview, params: { name: "base64_encode", input: "" }

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => true,
          "result" => ""
        )
      end

      it "returns empty result for missing transformation name" do
        post :preview, params: { name: "", input: "test" }

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => true,
          "result" => ""
        )
      end

      it "handles invalid transformation name" do
        post :preview, params: { name: "nonexistent", input: "test" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => false,
          "error" => "Transformation 'nonexistent' not found"
        )
      end

      it "handles invalid base64 input" do
        post :preview, params: { name: "base64_decode", input: "invalid_base64!" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => false
        )
        expect(json_response["error"]).to include("Input does not appear to be valid Base64")
      end
    end

    context "with transformation engine errors" do
      before do
        allow_any_instance_of(TransformationEngine).to receive(:apply).and_raise(StandardError.new("Engine error"))
      end

      it "returns error response" do
        post :preview, params: { name: "base64_encode", input: "test" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => false,
          "error" => "Engine error"
        )
      end
    end
  end

  describe "error handling" do
    context "when transformation loader fails" do
      before do
        allow_any_instance_of(TransformationLoaderService).to receive(:load_all).and_raise(TransformationLoaderError.new("Loader error"))
      end

      it "logs error and continues with graceful degradation" do
        expect(Rails.logger).to receive(:error).with(/Failed to initialize transformation engine/)

        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:engine)).to be_a(TransformationEngine)
      end
    end
  end
end
