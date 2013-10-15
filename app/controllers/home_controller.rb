class HomeController < ApplicationController
  respond_to :json, :html

  def index
    @company = Company.new unless user_signed_in? or company_signed_in?
  end

  def about
  end

  def contact
  end

  def create_contact
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to root_path, notice: 'Thanks for sending us a message, we will try to respond as quickly as possible'
    else
      flash[:error] = 'We had trouble trying to send your message.'
      render :contact
    end
  end

  def pricing
  end

  def terms_of_service
  end

  def privacy_policy
  end

  def get_matches
    if user_signed_in?
      @matches = current_user.match_listings_for_user
      respond_with({ job_listings: @matches, user_id: current_user.id })
    elsif company_signed_in?
      @matchings = current_company.match_users_per_listing
      respond_with({company_id: current_company.id, matchings: @matchings, fully_activated: current_company.fully_activated? })
    end
  end

  private

  def contact_params
    params.require(:contact_us).permit(:name, :phone, :email, :message)
  end
end
