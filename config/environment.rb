# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Pickemup::Application.initialize!
Stripe.api_key = ENV["STRIPE_API_KEY"]
