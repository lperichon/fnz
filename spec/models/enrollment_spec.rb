require 'spec_helper'

describe Enrollment do
  
  before(:each) do
    @membership = FactoryGirl.create(:membership)

    @attr = {
      :membership_id => @membership.id,
      :value => 3.2
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Enrollment.create!(@attr)
  end
  

  it "should require a membership" do
    no_membership_enrollment = Enrollment.new(@attr.merge(:membership_id => nil))
    no_membership_enrollment.should_not be_valid
  end

  it "should require a value" do
    no_value_enrollment = Enrollment.new(@attr.merge(:value => nil))
    no_value_enrollment.should_not be_valid
  end
end