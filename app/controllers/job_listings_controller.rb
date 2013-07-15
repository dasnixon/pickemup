class JobListingsController < ApplicationController
  before_filter :get_job_listing, only: [:show, :edit, :retrieve_listing]
  respond_to :json, :html

  def new
    @job_listing = JobListing.new
    @job_listing.populate_all_params
    respond_with @job_listing
  end

  def create
    @job_listing = JobListing.new
    remaining_params = @job_listing.unhash_all_params(job_listing_params)
    redirect_to root_path if @job_listing.update(remaining_params)
  end

  def show
  end

  def index
    @job_listings = JobListing.find_all_by_company_id(params[:company_id])
  end

  def edit
  end

  def update
    @job_listing = JobListing.find(params[:id])
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
    end
  end

  def retrieve_listing
    @job_listing.populate_all_params
    respond_with @job_listing
  end

  private

  def get_job_listing
    @job_listing = JobListing.find(params[:id])
  end

  def job_listing_params
    return_params = params.require(:job_listing).permit!.merge(company_id: params[:company_id])
  end
end
