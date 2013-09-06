class TechStacksController < ApplicationController
  before_filter :find_and_validate_company
  before_filter :find_tech_stack, only: [:retrieve_tech_stack, :update_tech_stack, :edit, :destroy]
  respond_to :json, :html

  def index
    @tech_stacks = @company.tech_stacks
  end

  def new
    @tech_stack = @company.tech_stacks.build
    @tech_stack.get_preference_defaults
    respond_with @tech_stack
  end

  def create
    @tech_stack = @company.tech_stacks.build
    remaining_params = TechStack.cleanup_invalid_data(tech_stack_params)
    if @tech_stack.update(remaining_params)
      respond_with(@company, location: nil, status: :created)
    else
      render json: { errors: @tech_stack.errors }, status: :bad_request
    end
  end

  def retrieve_tech_stack
    @tech_stack.get_preference_defaults
    respond_with @tech_stack
  end

  def update_tech_stack
    remaining_params = TechStack.cleanup_invalid_data(tech_stack_params)
    if @tech_stack.update(remaining_params)
      respond_with @tech_stack
    else
      render json: { errors: @tech_stack.errors }, status: :bad_request
    end
  end

  def destroy
    @tech_stack.destroy
    redirect_to company_tech_stacks_path(company_id: @company.id), notice: 'Successfully removed the tech stack.'
  end

  private

  def find_tech_stack
    @tech_stack = TechStack.find(params[:id])
  end

  def find_and_validate_company
    @company = Company.find(params[:company_id])
    check_invalid_permissions_company
  end

  def tech_stack_params
    params.require(:tech_stack).permit(:name).tap do |whitelisted|
      TechStack::HASHABLE_PARAMS.each do |hash_param|
        whitelisted[hash_param] = params[:tech_stack][hash_param]
      end
    end
  end
end
