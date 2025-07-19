# frozen_string_literal: true

# Refactored controller using domain services for transformation management
# Follows clean architecture principles with proper separation of concerns
class TransformationsController < ApplicationController
  before_action :set_transformation_registry
  before_action :set_transformation_engine, only: [ :index, :preview, :available ]

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
    result = @registry.load_all

    render json: {
      transformations: result.transformations.map do |transformation|
        {
          name: transformation.name,
          display_name: transformation.display_name,
          description: transformation.description,
          source_type: transformation.source_type
        }
      end,
      statistics: @registry.statistics
    }
  end

  # CRUD operations for database transformations
  def create
    transformation = @registry.create_transformation(
      name: transformation_params[:name],
      description: transformation_params[:description],
      version: transformation_params[:version] || "1.0.0",
      transformations: transformation_params[:transformations] || []
    )

    render json: {
      transformation: transformation.to_h,
      success: true,
      message: "Transformation created successfully"
    }, status: :created
  rescue TransformationRegistryService::ConflictError => e
    render json: {
      error: e.message,
      success: false
    }, status: :conflict
  rescue DatabaseTransformationAdapter::ValidationError => e
    render json: {
      error: e.message,
      success: false
    }, status: :unprocessable_entity
  end

  def show
    transformation = find_transformation_by_id_or_name

    render json: {
      transformation: transformation.to_h
    }
  rescue TransformationNotFoundError => e
    render json: {
      error: e.message,
      success: false
    }, status: :not_found
  end

  def update
    transformation = @registry.update_transformation(
      params[:id].to_i,
      transformation_update_params
    )

    render json: {
      transformation: transformation.to_h,
      success: true,
      message: "Transformation updated successfully"
    }
  rescue DatabaseTransformationAdapter::NotFoundError => e
    render json: {
      error: "Transformation not found",
      success: false
    }, status: :not_found
  rescue DatabaseTransformationAdapter::ValidationError => e
    render json: {
      error: e.message,
      success: false
    }, status: :unprocessable_entity
  end

  def destroy
    @registry.delete_transformation(params[:id].to_i)

    render json: {
      success: true,
      message: "Transformation deleted successfully"
    }
  rescue DatabaseTransformationAdapter::NotFoundError => e
    render json: {
      error: "Transformation not found",
      success: false
    }, status: :not_found
  end

  def list
    # List all available transformations with source information
    result = @registry.load_all

    render json: {
      transformations: result.transformations.map(&:to_h),
      statistics: @registry.statistics,
      errors: result.errors
    }
  end

  private

  def set_transformation_registry
    user_id = current_user_id # Stub for now
    @registry = TransformationRegistryService.new(user_id)
  end

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

  def find_transformation_by_id_or_name
    if params[:id].to_i > 0
      # Looking up by database ID
      transformation = @registry.load_by_id(params[:id].to_i)
      raise TransformationNotFoundError, "Transformation not found" unless transformation
      transformation
    else
      # Looking up by name
      transformation = @registry.load_by_name(params[:id])
      raise TransformationNotFoundError, "Transformation not found" unless transformation
      transformation
    end
  end

  def transformation_params
    params.permit(:name, :input, :description, :version, transformations: [])
  end

  def transformation_update_params
    params.permit(:description, :version, transformations: [])
  end

  def current_user_id
    # Stub method for user authentication
    # Returns nil for now (system transformations only)
    nil
  end

  class TransformationNotFoundError < StandardError; end
end
