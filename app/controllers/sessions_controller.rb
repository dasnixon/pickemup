class SessionsController < ApplicationController
  before_filter :check_if_logged_in, only: [:sign_in, :sign_up, :company]
  before_filter :check_github_synced, only: [:github]
  before_filter :check_linkedin_synced, only: [:linkedin]
  before_filter :check_stackexchange_synced, only: [:stackoverflow]

  def sign_in
  end

  def sign_up
  end

  def admin
    session[:admin_id] = nil
    admin = Admin.authenticate(params[:email], params[:password], request)
    if admin.present?
      session[:admin_id] = admin.id
      redirect_to admins_path, notice: "Signed in as Admin!"
    else
      session[:admin_id] = nil
      flash[:error] = "Unable to sign you in."
      redirect_to :back
    end
  end

  def company
    session[:user_id] = nil
    company = Company.authenticate(params[:email], params[:password], request)
    if company.present?
      session[:company_id] = company.id
      redirect_to root_path, notice: "Signed in!"
    else
      session[:company_id] = nil
      flash[:error] = "Unable to sign you in."
      render :sign_in
    end
  end

  def github
    session[:company_id] = nil
    if sync_user_github?
      if current_user.setup_github_account(request.env['omniauth.auth'])
        redirect_to_root('Sweet, we got your Github account!')
      else
        redirect_to root_path, alert: 'Unable to add your Github, try again later.'
      end
    else
      user = User.from_omniauth(request.env['omniauth.auth'], :github, request, true)
      if user.present?
        session[:user_id] = user.id
        redirect_to_root('You are signed in!')
      else
        session[:company_id] = session[:user_id] = nil
        redirect_to root_path, alert: 'Unable to add your Github, try again later. You may have another account in our system with the same email address.'
      end
    end
  end

  def linkedin
    session[:company_id] = nil
    if sync_user_linkedin?
      if current_user.setup_linkedin_account(request.env['omniauth.auth'])
        redirect_to_root('Sweet, we got your LinkedIn account!')
      else
        redirect_to root_path, alert: 'Unable to add your LinkedIn, try again later.'
      end
    else
      user = User.from_omniauth(request.env['omniauth.auth'], :linkedin, request, true)
      if user.present?
        session[:user_id] = user.id
        redirect_to_root('You are signed in!')
      else
        session[:user_id] = nil
        redirect_to root_url, alert: 'Unable to add your LinkedIn, try again later. You may have another account in our system with the same email address.'
      end
    end
  end

  def stackoverflow
    if current_user.build_stackexchange.from_omniauth(request.env['omniauth.auth'])
      redirect_to root_url, notice: 'Successfully linked your Stackoverflow profile!'
    else
      redirect_to root_url, alert: 'Unable to link your Stackoverflow profile!'
    end
  end

  def destroy
    session[:company_id] = session[:user_id] = nil
    redirect_to root_url, notice: 'Logged out!'
  end

  private

  def sync_user_linkedin?
    !company_signed_in? && user_signed_in? && current_user.github_uid.present? && current_user.linkedin_uid.blank?
  end

  def sync_user_github?
    !company_signed_in? && user_signed_in? && current_user.linkedin_uid.present? && current_user.github_uid.blank?
  end

  def check_github_synced
    redirect_to root_path, notice: 'Already have your github synced.' and return if user_signed_in? && current_user.github_uid.present?
  end

  def check_linkedin_synced
    redirect_to root_path, notice: 'Already have your linkedin synced.' and return if user_signed_in? && current_user.linkedin_uid.present?
  end

  def check_stackexchange_synced
    redirect_to root_path, alert: 'Must be logged in!' unless !company_signed_in? && user_signed_in? && from_stackexchange? && !current_user.stackexchange_synced
  end

  def redirect_to_root(notice)
    redirect_to root_path, notice: notice
  end

  def from_stackexchange?
    request.env['omniauth.auth'] && request.env['omniauth.auth'].provider == 'stackexchange'
  end

  def check_if_logged_in
    redirect_to root_path, alert: 'Already logged in.' and return if user_signed_in? || company_signed_in?
  end
end
