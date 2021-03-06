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

  describe "#calculate_balance" do
    let(:a){ Account.create!(@attr) }
    describe "wout balance checks" do
      before do
        a.update_balance
        expect(a.balance).to eq 0
      end
      it "+credits" do
        FactoryGirl.create(:transaction, source: a, type: "Credit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq 2.0
      end
      it "-debits" do
        FactoryGirl.create(:transaction, source: a, type: "Debit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq -2.0
      end
      it "-transfers from" do
        FactoryGirl.create(:transaction, source: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq -1.0
      end
      it "+transfer to" do
        FactoryGirl.create(:transaction, target: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 1.0
      end
      it "flow example" do
        FactoryGirl.create(:transaction, source: a, type: "Debit", amount: 1.0)
        FactoryGirl.create(:transaction, source: a, type: "Credit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq 1.0

        FactoryGirl.create(:transaction, source: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0

        FactoryGirl.create(:transaction, target: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 1.0
      end
      it "ignores other accounts debits and credits" do
        a.update_balance
        expect(a.balance).to eq 0

        FactoryGirl.create(:transaction, type: "Debit", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0
      end
      it "ignore pending transactions" do
        a.update_balance
        expect(a.balance).to eq 0

        FactoryGirl.create(:transaction,
                           state: "pending",
                           source: a,
                           type: "Debit",
                           amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0
      end
    end
    describe "with balance check" do
      let!(:bc){ FactoryGirl.create(:balance_check, account: a, balance: 13.2, checked_at: 1.minute.ago) }
      it "calculates balance with las balance check as base" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryGirl.create(:transaction, type: "Credit", source: a, amount: 1.1)

        a.update_balance
        expect(a.balance).to eq 14.3
      end
      it "ignores transactions before balance checked_at" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryGirl.create(:transaction, type: "Credit", source: a, amount: 1.1, transaction_at: bc.checked_at-1.minute)

        a.update_balance
        expect(a.balance).to eq 13.2
      end
      it "ignore pending transactions" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryGirl.create(:transaction,
                           state: "pending",
                           type: "Credit",
                           source: a,
                           amount: 1.1)

        a.update_balance
        expect(a.balance).to eq 13.2
      end
      it "considres reconciled transactions transacted before check but reconciled after" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryGirl.create(:transaction,
                           state: "reconciled",
                           type: "Credit",
                           source: a,
                           amount: 1.1,
                           transaction_at: bc.checked_at-1.day,
                           reconciled_at: Time.now
                          )

        a.update_balance
        expect(a.balance).to eq 14.3
      end
    end
  end


end
