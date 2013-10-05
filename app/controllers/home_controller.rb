class HomeController < ApplicationController
  def index
    if user_signed_in?
      @matchings = JobListing.all.map { |listing| listing.search_attributes(current_user.preference.id, current_user) }.compact
      @matchings.sort_by! { |matches| matches['score'].to_i }
    elsif company_signed_in?
      @matchings = current_company.match_users_per_listing
    else
      @company = Company.new
    end
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

  def company_search
    render json: Company.search_by(:name, params[:term])
  end

  def terms_of_service
  end

  def privacy_policy
  end

  private

  def contact_params
    params.require(:contact_us).permit(:name, :phone, :email, :message)
  end
end
