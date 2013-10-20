require 'spec_helper'

describe Sale do
  
  before(:each) do
    PadmaContact.stub(:find).and_return(PadmaContact.new(:first_name => "Homer", :last_name => "Simpson"))
    Contact.any_instance.stub(:padma).and_return([PadmaContact.new(:first_name => "Homer", :last_name => "Simpson")])
    @business = FactoryGirl.create(:business)
    @contact = FactoryGirl.create(:contact, :business => @business)
    @agent = FactoryGirl.create(:agent, :business => @business)
    @attr = {
      :contact_id => @contact.id,
      :business_id => @business.id,
      :agent_id => @agent.id,
      :sold_on => Date.today
    }
  end

  it "should create a new instance given a valid attribute" do
    Sale.create!(@attr)
  end


  it "should require a business" do
    no_business_sale = Sale.new(@attr.merge(:business_id => nil))
    no_business_sale.should_not be_valid
  end

  it "should create a new contact if necessary" do
    sale_with_padma_contact = Sale.create!(@attr.merge(:contact_id => nil, :padma_contact_id => "1234"))
    sale_with_padma_contact.contact.should_not be_nil
  end

end