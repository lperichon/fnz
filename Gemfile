source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.8'
gem 'rails', '~> 4.2'

gem 'puma'


##gem "sass", "~> 3.2.19"
gem 'sass-rails', '~> 5.0.7'
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 3.2'
gem 'jquery-rails'
gem "bootstrap-sass", "~> 2.1" #"2.0.4.0"
gem 'devise', '4.4.0'
gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.2.0"
gem "transitions", :require => ["transitions", "active_model/transitions"]

gem "awesome_nested_fields", "0.6.0"
gem 'awesome_nested_set', '3.3.1' # or any similar gem (gem 'nested_set')
gem "the_sortable_tree", "~> 2.5.0"

gem "simple_form", '~> 3.2.0'
gem "client_side_validations"
gem 'client_side_validations-simple_form', '~> 3.2.4'
gem 'bootstrap-datepicker-rails', "~> 1.1.1.11"
gem 'validates_timeliness', '~> 4.0'
gem "paperclip", "6.1"
gem 'aws-sdk'
#gem 'tz_magic'
gem "squeel", '~> 1.2.3'
gem 'logical_model', '~> 0.7.1'
gem 'accounts_client', '0.3.3'
gem 'contacts_client', '~> 0.0.47'
gem 'messaging_client','~> 0.2'
gem 'resque'
gem 'execjs', '2.7.0'
gem 'therubyracer'
gem "select2-rails"
gem 'momentjs-rails'
gem 'bootstrap-daterangepicker-rails'

gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem "workless", "~> 2.2.0"

gem "kaminari", '~> 1.2.1'
gem 'bootstrap-kaminari-views'
gem 'mandrill_mailer', github: "lperichon/mandrill_mailer"
gem 'httparty'
gem "active_model_serializers"
gem 'jquery-ui-rails'
#gem "cache_digests"
gem "wkhtmltopdf-heroku"
gem "pdfkit"
gem "paranoia", "~> 2.1.5"
##gem 'rake', '< 11.0'
gem "roo"
gem "roo-xls"
gem 'best_in_place', '~> 3.1.1'
gem "appsignal"
gem "translation"
gem "activeresource"

gem "pg", '0.21'

gem 'dalli', '2.6.4'

group :staging, :production do
  gem 'rails_12factor'
end

group :development do
  gem "hub", ">= 1.10.2", :require => nil
  gem 'quiet_assets'
end

group :development, :test do
  gem 'rspec-collection_matchers'
  gem "factory_bot_rails"
  gem "rspec-rails", '~> 3.9.1'
  gem "shoulda-matchers"
  gem "byebug"
end

group :test do
  gem "capybara", ">= 1.1.2"
  gem "email_spec", ">= 1.2.1"
  #gem "cucumber-rails", ">= 1.3.0", :require => false
  gem "database_cleaner", ">= 0.8.0"
  gem "launchy", ">= 2.1.2"
end

gem 'daemons'
gem "clockwork"
gem 'redis-rails'
