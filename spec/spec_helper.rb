# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'rspec/autorun'
require "paperclip/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Paperclip::Shoulda::Matchers

  config.before(:each) do
    User.any_instance.stub(:padma).and_return(PadmaUser.new)
    PadmaContact.stub(:find_by_kshema_id).and_return(PadmaContact.new(:id => "123", :first_name => "Bart", :last_name => "Simpson"))
    PadmaAccount.stub(:find).and_return(PadmaAccount.new(:name => "test"))
    PadmaAccount.any_instance.stub(:admin).and_return(PadmaUser.new(:username => "homer.simpson", :id => "homer.simpson", :email => "homer@simpsons.com"))
    PadmaAccount.any_instance.stub(:users).and_return([PadmaUser.new(:id => "bart.simpson", :email => "bart@simpsons.com"), PadmaUser.new(:id => "lisa.simpson", :email => "lisa@simpsons.com") ])
    PadmaUser.any_instance.stub(:enabled_accounts).and_return([PadmaAccount.new(:name => "test")])
    PadmaUser.any_instance.stub(:current_account_name).and_return("test")
  end
end