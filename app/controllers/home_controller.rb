class HomeController < ApplicationController
  def index
    if user_signed_in?
      @matchings = current_user.matching_companies
    elsif company_signed_in?
      @matchings = current_company.matching_users
    end
  end

  def about
  end

  def contact
  end

  def company_search
    render json: Company.search_by(:name, params[:term])
  end
end
