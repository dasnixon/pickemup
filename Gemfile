source 'https://rubygems.org'
ruby '2.0.0'

#MAGIC
gem 'rails'

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

#ENGLISH LANGUAGE MAGIC
gem 'indefinite_article'

#DOCUMENTING
group :doc do
  gem 'sdoc', require: false
end

#WEB SERVERS
gem 'unicorn'

#ENV VARIABLES (application.yml)
gem 'figaro'

#MANAGEMENT SYSTEMS
gem 'newrelic_rpm'

#HTML TEXT EDITOR
gem 'ckeditor_rails'

#OTHER
gem 'annotate'
gem 'httparty'
gem 'jbuilder'

group :production do
  gem 'rails_12factor'
end

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
