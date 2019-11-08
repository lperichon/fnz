require 'spec_helper'

describe GaliciaOfficeArImport do
  
  before(:each) do
    @business = FactoryGirl.create(:school)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/galicia_office_export.csv'), 'application/csv'),
      :business_id => @business.id,
      :account_id => @business.accounts.first.id,
      :status => :ready
    }

    User.current_user = @business.owner
  end

end
