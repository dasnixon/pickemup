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

#QUEUES
gem 'sidekiq'
gem 'sinatra'
gem 'slim'

#APIs
gem 'github_api'
gem 'serel', git: 'git://github.com/liamneesonsarm/serel.git' #stackoverflow may need to switch back to original if gets updated properly
gem 'stripe'
gem 'crunchbase'
gem 'linkedin-oauth2'

#AUTHENTICATION
gem 'oauth2'
gem 'omniauth-linkedin-oauth2'
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

#SEARCH AUTOCOMPLETION
gem 'soulmate_rails'
gem 'jquery-ui-rails'

#PAGINATION
gem 'will_paginate-bootstrap'

#TEXT EDITOR - BROSWER
gem 'codemirror-rails'

#OTHER
gem 'annotate'
gem 'httparty'
gem 'jbuilder'
gem 'redis'

#HTML Truncate Text
gem 'truncate_html'

group :production do
  #HEROKU
  gem 'rails_12factor'
end

group :test, :development do
  gem 'pry' #debugging
end

group :test do
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'timecop'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'rspec-sidekiq'
end

group :development do
  gem 'railroady' #schema diagrams
  gem 'meta_request' #for RailsPanel Google Chrome extension
end
