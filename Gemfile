source 'https://rubygems.org'

#MAGIC
gem 'rails', git: 'git://github.com/rails/rails.git', branch: '4-0-stable'

#DATABASES
gem 'pg'
gem 'pg-hstore'

#FRONT-END
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'uglifier'
gem 'font-awesome-rails'

#CRON
gem 'whenever', require: false

#STORE FILES/IMAGES
gem 'carrierwave'
gem 'fog'
gem 'rmagick'

#MESSAGING
gem 'mailboxer'

#ATTR SUPPORT
gem 'protected_attributes' #needed for mailboxer gem

#QUEUES
gem 'sidekiq'
gem 'sinatra'
gem 'slim'

#APIs
gem 'linkedin'
gem 'github_api'
gem 'serel', git: 'git://github.com/liamneesonsarm/serel.git' #stackoverflow may need to switch back to original if gets updated properly
gem 'stripe'
gem 'crunchbase'

#AUTHENTICATION
gem 'oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-github'
gem 'omniauth-stackexchange'
gem "bcrypt-ruby", :require => "bcrypt"

#JAVASCRIPT
gem 'angularjs-rails'
gem 'jquery-rails'
gem 'coffee-rails'

#DOCUMENTING
group :doc do
  gem 'sdoc', require: false
end

#WEB SERVERS
gem 'unicorn'

#ENV VARIABLES (application.yml)
gem 'figaro'

#OTHER
gem 'annotate'
gem 'httparty'
gem 'jbuilder'

group :test, :development do
  gem 'factory_girl_rails'
  gem 'pry' #debugging
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'railroady' #schema diagrams
end

group :development do
  gem 'meta_request' #for RailsPanel Google Chrome extension
end
