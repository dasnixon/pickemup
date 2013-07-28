class SessionsController < ApplicationController
  before_filter :check_if_logged_in, only: [:sign_in, :sign_up, :company, :github]

  def sign_in
  end

  def sign_up
    @company = Company.new
  end

  def company
    company = Company.authenticate(params[:email], params[:password])
    if company.present?
      session[:company_id] = company.id
      redirect_to root_path, notice: "Signed in!"
    else
      session[:company_id] = nil
      flash[:error] = "Unable to sign you in."
      redirect_to root_path
    end
  end

  def github
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.present?
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Signed in!'
    else
      session[:user_id] = nil
      redirect_to root_path, error: 'Unable to sign you in.'
    end
  end

  def linkedin
    redirect_to root_path, error: 'Must be logged in!' unless user_signed_in? && from_linkedin?
    if current_user.build_linkedin.from_omniauth(request.env['omniauth.auth'])
      redirect_to root_url, notice: 'Successfully linked your LinkedIn profile!'
    else
      redirect_to root_url, error: 'Unable to link your LinkedIn profile!'
    end
  end

  def destroy
    session[:company_id] = session[:user_id] = nil
    redirect_to root_url, notice: 'Logged out!'
  end

  def stackoverflow
    redirect_to root_path, error: 'Must be logged in!' unless user_signed_in? && from_stackexchange?
    if current_user.build_stackexchange.from_omniauth(request.env['omniauth.auth'])
      redirect_to root_url, notice: 'Successfully linked your Stackoverflow profile!'
    else
      redirect_to root_url, error: 'Unable to link your Stackoverflow profile!'
    end
  end

  private

  def from_linkedin?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].provider == 'linkedin_oauth2'
  end

  def from_stackexchange?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].provider == 'stackexchange'
  end

  def check_if_logged_in
    redirect_to root_path, error: 'Already logged in.' and return if user_signed_in? || company_signed_in?
  end
end
