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
    if current_user.build_linkedin.from_omniauth(request.env['omniauth.auth'], access_token.token)
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

  #Used to get the oauth2_access_token to make API calls for a user
  def access_token
    token = client.auth_code.get_token(params[:code], redirect_uri: "#{request.protocol}#{request.host_with_port}/auth/linkedin_oauth2/callback")
    @access_token ||= OAuth2::AccessToken.new(client, token.token, {
      :mode => :query,
      :param_name => "oauth2_access_token"
    })
  end

  def client
    OAuth2::Client.new(
      ENV['LINKEDIN_KEY'],
      ENV['LINKEDIN_SECRET'],
      :authorize_url => "/uas/oauth2/authorization?response_type=code", #LinkedIn's authorization path
      :token_url => "/uas/oauth2/accessToken", #LinkedIn's access token path
      :site => "https://www.linkedin.com"
     )
  end

  def from_linkedin?
    request.env['omniauth.auth'].provider == 'linkedin_oauth2'
  end
end
