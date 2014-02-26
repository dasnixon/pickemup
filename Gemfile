source 'https://rubygems.org'
ruby '2.1.0'

#MAGIC
gem 'rails', '~> 4.0.3'

#DATABASES
gem 'pg'
gem 'pg-hstore'

#FRONT-END
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'uglifier'
gem 'font-awesome-rails'
gem 'underscore-rails'

#CALENDAR/DATE
gem 'bootstrap-datetimepicker-rails'
gem 'fullcalendar-rails'

#JSON PARSING
gem 'multi_json'

#CRON
gem 'sidetiq'

#STORE FILES/IMAGES
gem 'carrierwave'
gem 'fog'
gem 'rmagick'
gem 'carrierwave_backgrounder' #background with sidekiq

#MESSAGING
gem 'mailboxer'

#QUEUES
gem 'sidekiq'
gem 'sinatra'
gem 'slim'

#INTERVIEW SCHEDULING
gem 'state_machine'

#APIs
gem 'github_api'
gem 'faraday', '0.8.0'
gem 'serel', git: 'git://github.com/liamneesonsarm/serel.git' #stackoverflow may need to switch back to original if gets updated properly
gem 'stripe'
gem 'crunchbase'
gem 'linkedin-oauth2'

#AUTHENTICATION
gem 'oauth2'
gem 'omniauth-linkedin-oauth2', '0.1.3'
gem 'omniauth-github'
gem 'omniauth-stackexchange'
gem 'bcrypt-ruby', require: 'bcrypt'

#JAVASCRIPT
gem 'angularjs-rails'
gem 'jquery-rails'
gem 'coffee-rails'

#ENGLISH LANGUAGE MAGIC
gem 'indefinite_article'
gem 'possessive'

#PHONE # VALIDATION
gem 'phony_rails'

#WEB SERVERS
gem 'unicorn'

#HTML TEXT EDITOR
gem 'ckeditor_rails'

#PAGINATION
gem 'will_paginate-bootstrap'

#TEXT EDITOR - BROSWER
#gem 'codemirror-rails'

#OTHER
gem 'httparty'
gem 'jbuilder'
gem 'redis'

#HTML Truncate Text
gem 'truncate_html', git: 'git://github.com/hgmnz/truncate_html.git'

#ANALYTICS
gem 'mixpanel'

group :production do
  #HEROKU
  gem 'rails_12factor'

  #MANAGEMENT SYSTEMS
  gem 'newrelic_rpm'
end

group :test, :development do
  gem 'pry' #debugging
  gem 'rspec-rails'
  gem 'jasmine-rails'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'timecop'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'ffaker'
  gem 'rspec-sidekiq'
end

group :development do
  gem 'annotate'
  gem 'figaro' #ENV VARIABLES (application.yml)
  gem 'consistency_fail'
  gem 'railroady' #schema diagrams
  gem 'meta_request' #for RailsPanel Google Chrome extension
  gem 'lol_dba'
end
