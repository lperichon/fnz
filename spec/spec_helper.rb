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

  #config.include FactoryBot::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
  config.infer_spec_type_from_file_location!
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.include Paperclip::Shoulda::Matchers

  config.before(:each) do
    allow_any_instance_of(User).to receive(:padma).and_return(PadmaUser.new)
    allow(PadmaContact).to receive(:find_by_kshema_id).and_return(PadmaContact.new(:id => "123", :first_name => "Bart", :last_name => "Simpson"))
    allow(PadmaAccount).to receive(:find).and_return(PadmaAccount.new(:name => "test", timezone: "UTC"))
    allow_any_instance_of(PadmaAccount).to receive(:admin).and_return(PadmaUser.new(:username => "homer.simpson", :id => "homer.simpson", :email => "homer@simpsons.com"))
    allow_any_instance_of(PadmaAccount).to receive(:users).and_return([PadmaUser.new(:id => "bart.simpson", :email => "bart@simpsons.com"), PadmaUser.new(:id => "lisa.simpson", :email => "lisa@simpsons.com") ])
    allow_any_instance_of(PadmaUser).to receive(:enabled_accounts).and_return([PadmaAccount.new(:name => "test")])
    allow_any_instance_of(PadmaUser).to receive(:current_account_name).and_return("test")
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
