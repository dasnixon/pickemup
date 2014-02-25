# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Pickemup::Application.initialize!

ENV["PICKEMUP_API_BASE_URL"] = Rails.env.production? ? "http://162.243.13.124/" : "http://127.0.0.1:9292/"
