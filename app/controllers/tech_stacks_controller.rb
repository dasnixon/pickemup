class TechStacksController < ApplicationController
  before_filter :find_tech_stack, only: [:retrieve_tech_stack, :update_tech_stack, :edit]
  before_filter :find_company, only: [:create, :index]
  respond_to :json, :html

  def new
    @tech_stack = TechStack.new(company_id: params[:company_id])
    @tech_stack.populate_all_params
    respond_with @tech_stack
  end

  def create
    @tech_stack = @company.tech_stacks.build
    remaining_params = @tech_stack.unhash_all_params(tech_stack_params)
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
    @tech_stack.populate_all_params
    respond_with @tech_stack
  end

  def update_tech_stack
    remaining_params = @tech_stack.unhash_all_params(tech_stack_params)
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

  def find_company
    @company = Company.find(params[:company_id])
  end

  def tech_stack_params
    params.require(:tech_stack).permit!.merge(company_id: params[:company_id])
  end
end
