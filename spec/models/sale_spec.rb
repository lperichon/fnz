require 'spec_helper'

describe Sale do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @contact = FactoryGirl.create(:contact, :business => @business)
    @attr = { 
      :contact_id => @contact.id,
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Sale.create!(@attr)
  end
  

  it "should require a business" do
    no_business_sale = Sale.new(@attr.merge(:business_id => nil))
    no_business_sale.should_not be_valid
  end

end