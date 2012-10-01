require 'spec_helper'

describe Transaction do
  
  before(:each) do
    class Debit < Transaction

    end

    @account = FactoryGirl.create(:account)
    @attr = {
      :description => "Example Transaction",
      :business_id => @account.business.id,
      :source_id => @account.id,
      :amount => 3.5
    }

    User.current_user = @account.business.owner
  end

  it "should create a new instance given a valid attribute" do
    Debit.create!(@attr)
  end
  
  it "should require a description" do
    no_desc_transaction = Transaction.new(@attr.merge(:description => ""))
    no_desc_transaction.should_not be_valid
  end

  it "should require an amount" do
    no_amount_transaction = Transaction.new(@attr.merge(:amount => ""))
    no_amount_transaction.should_not be_valid
  end

  it "should require a positive amount" do
    negative_amount_transaction = Transaction.new(@attr.merge(:amount => -10.5))
    negative_amount_transaction.should_not be_valid
  end

  it "should set the business based on the source account" do
    no_business_transaction = Transaction.new(@attr.merge(:business_id => nil))
    no_business_transaction.should be_valid
  end

  it "should require a source account" do
    no_source_transaction = Transaction.new(@attr.merge(:source_id => nil))
    no_source_transaction.should_not be_valid
  end

  it "should import from csv row" do
    transaction = Transaction.build_from_csv(@account.business, [@account.name, Date.today, 2.1, "Test import transaction"])
    transaction.should be_valid
  end
end