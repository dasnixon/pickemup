Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin_oauth2, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], scope: 'r_fullprofile r_emailaddress r_network r_contactinfo'
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,public_repo,gist"
end
