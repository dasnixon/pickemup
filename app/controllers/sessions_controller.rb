class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.present?
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Signed in!'
    else
      session[:user_id] = nil
      redirect_to root_path, error: 'Unable to sign you in.'
    end
  end

  def update
    redirect_to root_path, error: 'Must be logged in!' unless user_signed_in? && from_linkedin?
    if current_user.update_linkedin_info(request.env['omniauth.auth'])
      redirect_to root_url, notice: 'Successfully linked your LinkedIn profile!'
    else
      redirect_to root_url, error: 'Unable to link your LinkedIn profile!'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: 'Logged out!'
  end

  private

  def from_linkedin?
    request.env['omniauth.auth'].provider == 'linkedin_oauth2'
  end
end
