class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :current_company, :user_signed_in?,
    :company_signed_in?

  def check_invalid_permissions_user
    redirect_to root_path, error: 'You do not have permissions to view this page' if not_valid_user?
  end

  def check_invalid_permissions_company
    redirect_to root_path, error: 'You do not have permissions to view this page' if not_valid_company?
  end

  def get_and_check_user
    @user ||= User.find(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

  def get_and_check_company
    @company ||= Company.find(params[:id])
    redirect_to root_path unless current_company?(@company)
  end

  private

  def current_user?(user)
    current_user == user
  end

  def current_company?(company)
    current_company == company
  end

  def current_company
    @current_company ||= Company.find(session[:company_id]) if session[:company_id]
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def not_valid_user?
    !user_signed_in? || current_user != @user
  end

  def not_valid_company?
    !company_signed_in? || current_company != @company
  end

  def user_signed_in?
    current_user.present?
  end

  def company_signed_in?
    current_company.present?
  end
end
