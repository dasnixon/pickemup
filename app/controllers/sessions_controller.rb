class SessionsController < ApplicationController
  before_filter :check_if_logged_in, only: [:sign_in, :sign_up, :company]

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
    redirect_to root_path, notice: 'Already have your github synced.' and return if user_signed_in? && current_user.github_uid.present?
    if user_signed_in? && current_user.linkedin_uid.present? && current_user.github_uid.blank? #they already setup a profile from linkedin
      current_user.setup_github_account(request.env['omniauth.auth'])
    else
      user = User.from_omniauth(request.env['omniauth.auth'], :github)
    end
    if user_signed_in?
      redirect_to_root('Sweet, we got your Github account!')
    elsif user.present?
      session[:user_id] = user.id
      redirect_to_root('You are signed in!')
    else
      session[:user_id] = nil
      redirect_to root_path, error: 'Unable to add your Github, try again.'
    end
  end

  def linkedin
    redirect_to root_path, notice: 'Already have your linkedin synced.' and return if user_signed_in? && current_user.linkedin_uid.present?
    if user_signed_in? && current_user.github_uid.present? && current_user.linkedin_uid.blank?
      current_user.setup_linkedin_account(request.env['omniauth.auth'])
    else
      user = User.from_omniauth(request.env['omniauth.auth'], :linkedin)
    end
    if user_signed_in?
      redirect_to_root('Sweet, we got your LinkedIn account!')
    elsif user.present?
      session[:user_id] = user.id unless user_signed_in?
      redirect_to_root('You are signed in!')
    else
      session[:user_id] = nil
      redirect_to root_url, error: 'Unable to add your LinkedIn, try again.'
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

  def redirect_to_root(notice)
    redirect_to root_path, notice: notice
  end

  def from_stackexchange?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].provider == 'stackexchange'
  end

  def check_if_logged_in
    redirect_to root_path, error: 'Already logged in.' and return if user_signed_in? || company_signed_in?
  end
end
