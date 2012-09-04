require 'spec_helper'

describe Agent do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Agent",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Agent.create!(@attr)
  end
  
  it "should require a name" do
    no_name_agent = Agent.new(@attr.merge(:name => ""))
    no_name_agent.should_not be_valid
  end

  it "should require a business" do
    no_business_agent = Agent.new(@attr.merge(:business_id => nil))
    no_business_agent.should_not be_valid
  end

end