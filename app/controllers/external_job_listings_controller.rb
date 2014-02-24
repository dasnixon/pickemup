class ExternalJobListingsController < ApplicationController
  protect_from_forgery except: :create
  respond_to :json, :html

  def create
    job_listing = ExternalJobListing.new(listing_params)
    if job_listing.save!
      render text: "OK", status: 200
    else
      render text: "Error", status: 500
    end
  end

  private

  def listing_params
    params.require(:job_listing).permit(:job_title, :link, :job_description, :creation_time,
                                        :skills, :salary_range_low, :salary_range_high, :company_url)
  end
end
