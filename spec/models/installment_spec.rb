require 'spec_helper'

describe Installment do
  
  before(:each) do
    @membership = FactoryGirl.create(:membership)
    @agent = FactoryGirl.create(:agent, :business => @membership.business)
    @attr = {
      :membership_id => @membership.id,
      :agent_id => @agent.id,
      :due_on => Date.today.beginning_of_month,
      :value => 3.2
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Installment.create!(@attr)
  end
  

  it "should require a membership" do
    no_membership_installment = Installment.new(@attr.merge(:membership_id => nil))
    no_membership_installment.should_not be_valid
  end

  it "should require an agent" do
    no_agent_installment = Installment.new(@attr.merge(:agent_id => nil))
    no_agent_installment.should_not be_valid
  end

  it "should require a due date" do
    no_due_installment = Installment.new(@attr.merge(:due_on => nil))
    no_due_installment.should_not be_valid
  end

  it "should require a value" do
    no_value_installment = Installment.new(@attr.merge(:value => nil))
    no_value_installment.should_not be_valid
  end
end