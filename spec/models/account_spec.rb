require 'spec_helper'

describe Account do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Account",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Account.create!(@attr)
  end
  
  it "should require a name" do
    no_name_account = Account.new(@attr.merge(:name => ""))
    no_name_account.should_not be_valid
  end

  it "should require a business" do
    no_business_account = Account.new(@attr.merge(:business_id => nil))
    no_business_account.should_not be_valid
  end

end