require 'rails_helper'

describe Enrollment do
  
  before(:each) do
    @membership = FactoryBot.create(:membership)
    @agent = FactoryBot.create(:agent, :business => @membership.business)

    @attr = {
      :membership_id => @membership.id,
      :agent_id => @agent.id,
      :value => 3.2,
      :enrolled_on => Date.today
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Enrollment.create!(@attr)
  end

  it "should require a membership" do
    no_membership_enrollment = Enrollment.new(@attr.merge(:membership_id => nil))
    no_membership_enrollment.should_not be_valid
  end

  it "should require an agent" do
    no_agent_enrollment = Enrollment.new(@attr.merge(:agent_id => nil))
    no_agent_enrollment.should_not be_valid
  end

  it "should require a value" do
    no_value_enrollment = Enrollment.new(@attr.merge(:value => nil))
    no_value_enrollment.should_not be_valid
  end
end