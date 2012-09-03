require 'spec_helper'

describe Contact do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Contact",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Contact.create!(@attr)
  end
  
  it "should require a name" do
    no_name_contact = Contact.new(@attr.merge(:name => ""))
    no_name_contact.should_not be_valid
  end

  it "should require a business" do
    no_business_contact = Contact.new(@attr.merge(:business_id => nil))
    no_business_contact.should_not be_valid
  end

end