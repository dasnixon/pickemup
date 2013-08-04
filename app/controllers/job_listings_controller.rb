class JobListingsController < ApplicationController
  before_filter :find_company
  before_filter :check_invalid_permissions_company, except: [:index, :show]
  before_filter :check_for_subscription, only: [:new, :create]
  before_filter :get_job_listing, only: [:show, :edit, :update, :destroy, :retrieve_listing]
  respond_to :json, :html

  def new
    @job_listing = JobListing.new
    listing_response
  end

  def create
    @job_listing = @company.job_listings.build
    remaining_params = @job_listing.unhash_all_params(job_listing_params)
    if @job_listing.update(remaining_params)
      respond_with @job_listing
    else
      render json: { errors: @job_listing.errors }, status: :bad_request
    end
  end

  def show
  end

  def index
    @job_listings = JobListing.find_all_by_company_id(params[:company_id], order: "active = false")
  end

  def edit
  end

  def update
    if @job_listing.update(job_listing_params)
      redirect_to root_path, notice: "Listing updated"
    else
      flash[:error] = "Something went wrong"
      render :edit
    end
  end

  def update_listing
    @job_listing = JobListing.find(params[:job_listing_id])
    remaining_params = @job_listing.unhash_all_params(job_listing_params)
    if @job_listing.update(remaining_params)
      respond_with(@job_listing)
    else
      render json: { errors: @job_listing.errors }, status: :bad_request
    end
  end

  def retrieve_listing
    listing_response
  end

  def destroy
    @job_listing.destroy
    redirect_to company_job_listings_path(company_id: @company.id), notice: "Listing has been removed."
  end

  def toggle_active
    @job_listing = JobListing.find(params[:id])
    if @job_listing
      @job_listing.active = !@job_listing.active
      @job_listing.save
      redirect_to company_job_listings_path(company_id: params[:company_id], id: params[:id])
    else
      redirect_to :back
    end
  end

  private

  def check_for_subscription
    subscription = @company.subscription
    unless subscription && subscription.active?
      click_here_subscription = "<a href='/companies/#{@company.id}/subscriptions/new'>here</a>"
      notice = "You need to setup a subscription before you can add job listings, click #{click_here_subscription} to add a subscription"
      redirect_to company_job_listings_path(company_id: @company.id), notice: notice
    end
  end

  def get_job_listing
    @job_listing = @company.job_listings.find(params[:id])
  end

  def job_listing_params
    params.require(:job_listing).permit!.merge(company_id: params[:company_id])
  end

  def find_company
    @company ||= Company.find(params[:company_id])
  end

  def listing_response
    @job_listing.populate_all_params
    tech_stacks = Company.find(params[:company_id]).tech_stacks
    @tech_stack_choices = tech_stacks.map { |stack| {name: stack.name, id: stack.id} }
    @response = {job_listing: @job_listing, tech_stacks: @tech_stack_choices}
    respond_with @response
  end
end
