source 'https://rubygems.org'
ruby '2.1.3'
gem 'rails', '4.0.4'
gem 'sass-rails', '~> 4.0.2'
gem 'compass-rails', '~> 1.1.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer'
gem 'less-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'pg'
gem 'devise'
gem 'formtastic', github: 'justinfrench/formtastic'
gem 'formtastic-bootstrap', github: '0xCCD/formtastic-bootstrap'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'paperclip', '~> 4.1'
gem 'font-awesome-rails'
gem 'rest-client'
gem 'awesome_print'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'
gem 'whenever', :require => false
gem 'premailer-rails'
gem 'nokogiri'
gem 'intercom-rails', '~> 0.2.24'
gem 'event_tracker'
gem 'breadcrumbs_on_rails'

group :development do
  gem 'quiet_assets'
  gem 'faker'
  gem 'xray-rails'
end

# group :test do
#   gem 'rspec-rails'
#   gem 'factory_girl_rails'
#   gem 'capybara'
#   gem 'capybara-webkit'
#   gem 'headless'
#   gem 'mocha'
#   gem 'launchy'
#   gem 'shoulda-matchers'
# end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry'
  gem 'pry-nav'
end

group :staging, :production do
  # heroku only
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'aws-sdk'
  gem 'unicorn'
end
