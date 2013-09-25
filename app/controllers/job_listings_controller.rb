class JobListingsController < ApplicationController
  before_filter :find_company
  before_filter :check_invalid_permissions_company, except: [:index, :show]
  before_filter :check_for_subscription, only: [:new, :create]
  before_filter :get_job_listing, except: [:index, :new, :create, :guide]
  before_filter :cleanup_invalid_data, only: [:create, :update_listing]
  respond_to :json, :html

  def index
    @job_listings = @company.job_listings.order('active DESC, updated_at DESC').paginate(page: params[:page], per_page: 4)
  end

  def show
  end

  def guide
    @subscription = current_company.subscription
    @has_tech_stacks = current_company.tech_stacks.exists?
  end

  def new
    unless @company.subscription.maxed_out?
      @job_listing = @company.job_listings.build
      listing_response
    else
      flash[:error] = "Can't create a new job listing.  You've reached your subscription limit."
      redirect_to company_job_listings_path(company_id: @company.id)
    end
  end

  def create
    @job_listing = @company.job_listings.build
    if @job_listing.update(@bathed_params)
      @job_listing.api_create
      respond_with(@job_listing, location: nil, status: :created)
    else
      render json: { errors: @job_listing.errors }, status: :bad_request
    end
  end

  def update_listing
    if @job_listing.update(@bathed_params)
      @job_listing.api_update
      respond_with @job_listing
    else
      render json: { errors: @job_listing.errors }, status: :bad_request
    end
  end

  def retrieve_listing
    listing_response
  end

  def destroy
    @job_listing.destroy
    @job_listing.api_destroy
    redirect_to company_job_listings_path(company_id: @company.id), notice: 'Listing has been successfully removed.'
  end

  def toggle_active
    if !@company.subscription.maxed_out? || @job_listing.active
      @job_listing.toggle_active
      redirect_to company_job_listings_path(company_id: @company.id), notice: "Successfully #{@job_listing.active? ? 'activated' : 'deactivated'} your job listing."
    else
      flash[:error] = "Can't activate another job listing.  You've reached your subscription limit"
      redirect_to company_job_listings_path(company_id: @company.id)
    end
  end

  private

  def cleanup_invalid_data
    @bathed_params = JobListing.cleanup_invalid_data(job_listing_params)
  end

  def check_for_subscription
    subscription = @company.subscription
    unless subscription and subscription.active?
      click_here_subscription = "<a href='/companies/#{@company.id}/subscriptions/new'>here</a>"
      notice = "You need to setup a subscription before you can add job listings, click #{click_here_subscription} to add a subscription"
      redirect_to company_job_listings_path(company_id: @company.id), notice: notice and return
    end
  end

  def get_job_listing
    @job_listing = JobListing.find(params[:id])
  end

  def job_listing_params
    params.require(:job_listing).permit(:job_title, :job_description, :estimated_work_hours, :salary_range_low,
    :salary_range_high, :vacation_days, :healthcare, :equity, :bonuses, :retirement, :fulltime, :remote, :hiring_time,
    :tech_stack_id, :location, :company_id, :active, :sponsorship_available, :dental, :vision, :life_insurance).tap do |whitelisted|
      JobListing::HASHABLE_PARAMS.each do |hash_param|
        whitelisted[hash_param] = params[:job_listing][hash_param] #our cleanup_invalid_data method handles invalid data here
      end
    end
  end

  def find_company
    @company = Company.find(params[:company_id])
  end

  def listing_response
    @job_listing.get_preference_defaults
    listing_response = { job_listing: @job_listing , tech_stacks: @company.collected_tech_stacks }
    respond_with listing_response
  end
end
