require 'spec_helper'

describe Import do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = {
      :upload => Rack::Test::UploadedFile.new('spec/support/transactions.csv', 'text/csv'),
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Import.create!(@attr)
  end

  it "should require a business" do
    no_business_import = Import.new(@attr.merge(:business_id => nil))
    no_business_import.should_not be_valid
  end

  it { should have_attached_file(:upload) }
  it { should validate_attachment_presence(:upload) }
  it { should validate_attachment_content_type(:upload).
                  allowing('text/csv').
                  rejecting('image/png', 'image/gif') }

end