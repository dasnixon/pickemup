class TechStacksController < ApplicationController
  before_filter :find_and_validate_company
  before_filter :find_tech_stack, only: [:retrieve_tech_stack, :update_tech_stack, :edit]
  respond_to :json, :html

  def new
    @tech_stack = TechStack.new(company_id: params[:company_id])
    @tech_stack.get_preference_defaults
    respond_with @tech_stack
  end

  def create
    @tech_stack = @company.tech_stacks.build
    remaining_params = TechStack.cleanup_invalid_data(tech_stack_params)
    if @tech_stack.update(remaining_params)
      respond_with @tech_stack
    else
      render json: { errors: @tech_stack.errors }, status: :bad_request
    end
  end

  def index
    @tech_stacks = @company.tech_stacks if @company
  end

  def retrieve_tech_stack
    @tech_stack.get_preference_defaults
    respond_with @tech_stack
  end

  def update_tech_stack
    remaining_params = TechStack.cleanup_invalid_data(tech_stack_params)
    if @tech_stack.update(remaining_params)
      respond_with(@tech_stack)
    else
      render json: { errors: @tech_stack.errors }, status: :bad_request
    end
  end

  private

  def find_tech_stack
    @tech_stack = TechStack.find(params[:id])
  end

  def find_and_validate_company
    @company ||= Company.find(params[:company_id])
    check_invalid_permissions_company
  end

  def tech_stack_params
    params.require(:tech_stack).permit!
  end
end
