require 'spec_helper'

describe Tag do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Tag",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Tag.create!(@attr)
  end
  
  it "should require a name" do
    no_name_tag = Tag.new(@attr.merge(:name => ""))
    no_name_tag.should_not be_valid
  end

  it "should require a business" do
    no_business_tag = Tag.new(@attr.merge(:business_id => nil))
    no_business_tag.should_not be_valid
  end

end
