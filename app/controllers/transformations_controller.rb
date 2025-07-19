# frozen_string_literal: true

# Controller for handling transformation requests via web interface
# Follows SRP by focusing solely on HTTP request/response handling
class TransformationsController < ApplicationController
  before_action :set_transformation_engine

  def index
    # Show the main transformation interface
  end

  def preview
    # Real-time transformation preview via AJAX
    render json: {
      result: perform_transformation,
      success: true
    }
  rescue StandardError => e
    render json: {
      error: e.message,
      success: false
    }, status: :unprocessable_entity
  end

  def available
    # Return available transformations for dropdown
    render json: {
      transformations: available_transformations_list
    }
  end

  private

  def set_transformation_engine
    @engine = TransformationEngine.new
    @loader = TransformationLoaderService.new(@engine)
    @loader.load_all
  rescue TransformationLoaderError => e
    Rails.logger.error "Failed to initialize transformation engine: #{e.message}"
    # Continue with empty engine for graceful degradation
  end

  def perform_transformation
    return "" unless transformation_params[:input].present? && transformation_params[:name].present?

    input = transformation_params[:input]
    transformation_name = transformation_params[:name]

    # Validate input first
    validation_result = @engine.validate_input(transformation_name, input)
    unless validation_result.valid?
      raise StandardError, validation_result.errors.join(", ")
    end

    # Apply transformation
    @engine.apply(transformation_name, input)
  end

  def available_transformations_list
    @loader&.available_transformations || []
  end

  def transformation_params
    params.permit(:name, :input)
  end
end
