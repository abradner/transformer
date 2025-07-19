# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransformationsController, type: :controller do
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

  before do
    # Mock transformation engine to avoid engine setup complexity
    allow_any_instance_of(TransformationLoaderService).to receive(:load_all)
    allow_any_instance_of(TransformationEngine).to receive(:validate_input).and_return(double(valid?: true))
    allow_any_instance_of(TransformationEngine).to receive(:apply).and_return("transformed output")
  end

  describe "GET #available" do
    it "returns available transformations from both sources" do
      get :available

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key("transformations")
      expect(json_response).to have_key("statistics")
      expect(json_response["transformations"]).to be_an(Array)

      # Should include file-based transformations
      names = json_response["transformations"].map { |t| t["name"] }
      expect(names).to include("log_level_highlighter")
    end
  end

  describe "GET #list" do
    it "returns all transformations with source information" do
      get :list

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key("transformations")
      expect(json_response).to have_key("statistics")
      expect(json_response).to have_key("errors")
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name: "test_transform",
        description: "Test transformation",
        version: "1.0.0",
        transformations: sample_transformations
      }
    end

    it "creates a new database transformation" do
      post :create, params: valid_attributes

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be true
      expect(json_response["transformation"]["name"]).to eq("test_transform")
    end

    it "returns conflict error for name collision with file-based transformation" do
      post :create, params: valid_attributes.merge(name: "log_level_highlighter")

      expect(response).to have_http_status(:conflict)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be false
      expect(json_response["error"]).to include("already exists")
    end

    it "returns validation error for invalid data" do
      post :create, params: valid_attributes.merge(name: "")

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be false
    end
  end

  describe "GET #show" do
    let!(:transformation) do
      TransformationRegistryService.new.create_transformation(
        name: "show_test",
        description: "For show test",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "shows transformation by ID" do
      get :show, params: { id: transformation.source_id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["transformation"]["name"]).to eq("show_test")
    end

    it "shows file-based transformation by name" do
      get :show, params: { id: "log_level_highlighter" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["transformation"]["name"]).to eq("log_level_highlighter")
    end

    it "returns not found for non-existent transformation" do
      get :show, params: { id: "non_existent" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH #update" do
    let!(:transformation) do
      TransformationRegistryService.new.create_transformation(
        name: "update_test",
        description: "Original description",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "updates transformation" do
      patch :update, params: {
        id: transformation.source_id,
        description: "Updated description"
      }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be true
      expect(json_response["transformation"]["description"]).to eq("Updated description")
    end

    it "returns not found for non-existent transformation" do
      patch :update, params: { id: 99999, description: "test" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE #destroy" do
    let!(:transformation) do
      TransformationRegistryService.new.create_transformation(
        name: "delete_test",
        description: "To be deleted",
        version: "1.0.0",
        transformations: sample_transformations
      )
    end

    it "deletes transformation" do
      delete :destroy, params: { id: transformation.source_id }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be true
    end

    it "returns not found for non-existent transformation" do
      delete :destroy, params: { id: 99999 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #preview" do
    it "performs transformation preview" do
      post :preview, params: {
        name: "log_level_highlighter",
        input: "ERROR: Something went wrong"
      }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be true
      expect(json_response["result"]).to eq("transformed output")
    end

    it "returns error for invalid transformation" do
      allow_any_instance_of(TransformationEngine).to receive(:validate_input)
        .and_return(double(valid?: false, errors: [ "Invalid input" ]))

      post :preview, params: {
        name: "log_level_highlighter",
        input: "test"
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)

      expect(json_response["success"]).to be false
    end
  end
end
