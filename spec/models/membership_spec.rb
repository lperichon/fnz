require 'spec_helper'

describe Membership do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @contact = FactoryGirl.create(:contact, :business => @business)
    @attr = {
      :contact_id => @contact.id,
      :business_id => @business.id,
      :begins_on => Date.today.beginning_of_month,
      :ends_on => 11.months.from_now.end_of_month
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Membership.create!(@attr)
  end
  

  it "should require a business" do
    no_business_membership = Membership.new(@attr.merge(:business_id => nil))
    no_business_membership.should_not be_valid
  end


  it "should require a contact" do
    no_contact_membership = Membership.new(@attr.merge(:contact_id => nil))
    no_contact_membership.should_not be_valid
  end

  it "should require a starting date" do
    no_start_membership = Membership.new(@attr.merge(:begins_on => nil))
    no_start_membership.should_not be_valid
  end

  it "should require an ending date" do
    no_end_membership = Membership.new(@attr.merge(:ends_on => nil))
    no_end_membership.should_not be_valid
  end

  it "should require an ending date after the starting date" do
    date_conflict_membership = Membership.new(@attr.merge(:ends_on => 10.years.ago))
    date_conflict_membership.should_not be_valid
  end
end