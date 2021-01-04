require 'spec_helper'

describe Transfer do
  
  before(:each) do
    @account = FactoryBot.create(:account)
    @account2 = FactoryBot.create(:account, :business => @account.business)
    @attr = {
      :description => "Example Transaction",
      :business_id => @account.business.id,
      :source_id => @account.id,
      :target_id => @account2.id,
      :amount => 3.5
    }
  end

  it "should require a conversion rate" do
    no_conversion_rate_transaction = Transfer.new(@attr.merge(:conversion_rate => ""))
    expect(no_conversion_rate_transaction).not_to be_valid
  end

  it "should require a positive conversion_rate" do
    negative_conversion_rate_transaction = Transfer.new(@attr.merge(:conversion_rate => -1.5))
    expect(negative_conversion_rate_transaction).not_to be_valid
  end

  it "should require a target account" do
    no_target_transaction = Transfer.new(@attr.merge(:target_id => nil))
    expect(no_target_transaction).not_to be_valid
  end
end
