source 'https://rubygems.org'

gem 'rails', '4.0.0'

#DATABASES
gem 'pg'
gem 'pg-hstore'

#FRONT-END
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'font-awesome-rails'

#CRON
gem 'whenever', require: false

#Queues
gem 'sidekiq'
gem 'sinatra'
gem 'slim'

#APIs
gem 'linkedin'
gem 'github_api'
gem 'serel', git: 'git://github.com/liamneesonsarm/serel.git' #stackoverflow may need to switch back to original if gets updated properly
gem 'stripe'

#AUTHENTICATION
gem 'oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-github'
gem 'omniauth-stackexchange'
gem "bcrypt-ruby", :require => "bcrypt"

#JAVASCRIPT
gem 'angularjs-rails'
gem 'jquery-rails'
gem 'coffee-rails', '~> 4.0.0'

gem 'jbuilder', '~> 1.2'

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


group :test, :development do
  gem 'factory_girl_rails'
  gem 'pry' #debugging
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'railroady' #schema diagrams
end
