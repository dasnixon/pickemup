class HomeController < ApplicationController
  def index
    if user_signed_in?
      @matchings = current_user.matching_companies
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
