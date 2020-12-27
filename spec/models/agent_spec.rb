require 'spec_helper'

describe Agent do
  
  before(:each) do
    @business = FactoryBot.create(:business)
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
    expect(no_name_agent).not_to be_valid
  end

  it "should require a business" do
    no_business_agent = Agent.new(@attr.merge(:business_id => nil))
    expect(no_business_agent).not_to be_valid
  end

end
