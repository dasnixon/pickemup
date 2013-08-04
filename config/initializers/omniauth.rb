Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], scope: 'r_fullprofile r_emailaddress r_network r_contactinfo'
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user,public_repo,gist'
  provider :stackexchange, ENV['STACKEXCHANGE_CLIENT_ID'], ENV['STACKEXCHANGE_CLIENT_SECRET'], public_key: ENV['STACKEXCHANGE_PUB_KEY'], site: 'stackoverflow', scope: 'no_expiry'
end
