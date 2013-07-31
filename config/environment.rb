# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Pickemup::Application.initialize!
Stripe.api_key = ENV["STRIPE_API_KEY"]
Crunchbase::API.key = ENV["CRUNCHBASE_KEY"]

ActionMailer::Base.smtp_settings = {
  :user_name => ENV["SENDGRID_USERNAME"],
  :password => ENV["SENDGRID_PASSWORD"],
  :domain => "localhost:8080",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options[:host] = "localhost:8080"
