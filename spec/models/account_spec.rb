require 'spec_helper'

describe Account do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Account",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Account.create!(@attr)
  end
  
  it "should require a name" do
    no_name_account = Account.new(@attr.merge(:name => ""))
    no_name_account.should_not be_valid
  end

  it "should require a business" do
    no_business_account = Account.new(@attr.merge(:business_id => nil))
    no_business_account.should_not be_valid
  end

  it "defaults currency to business's currency" do
    b = FactoryGirl.create(:business, currency_code: "ars")
    a = FactoryGirl.build(:account, business_id: b.id)
    a.save
    expect(a.currency.iso_code.downcase).to eq b.currency_code.downcase
  end


end
