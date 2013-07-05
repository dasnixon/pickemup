class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?, :company_signed_in?

  private

  def current_user
    @current_user ||=
    if session[:company_id]
      Company.find(session[:company_id])
    elsif session[:user_id]
      User.find(session[:user_id])
    end
  end

  def user_signed_in?
    current_user.present? && current_user.class.name == "User"
  end

  def company_signed_in?
    current_user.present? && current_user.class.name == "Company"
  end
end
