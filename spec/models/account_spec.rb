require 'rails_helper'

describe Account do
  
  before(:each) do
    @business = FactoryBot.create(:business)
    @attr = { 
      :name => "Example Account",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    a = FactoryBot.build(:account, @attr)
    expect(a).to be_valid
  end
  
  it "should require a name" do
    no_name_account = Account.new(@attr.merge(:name => ""))
    expect(no_name_account).not_to be_valid
  end

  it "should require a business" do
    no_business_account = Account.new(@attr.merge(:business_id => nil))
    expect(no_business_account).not_to be_valid
  end


  describe "#calculate_balance" do
    let(:a){ Account.create!(@attr) }
    describe "wout balance checks" do
      before do
        a.update_balance
        expect(a.balance).to eq 0
      end
      it "+credits" do
        FactoryBot.create(:transaction, source: a, type: "Credit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq 2.0
      end
      it "-debits" do
        FactoryBot.create(:transaction, source: a, type: "Debit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq -2.0
      end
      it "-transfers from" do
        FactoryBot.create(:transaction, source: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq -1.0
      end
      it "+transfer to" do
        FactoryBot.create(:transaction, target: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 1.0
      end
      it "flow example" do
        FactoryBot.create(:transaction, source: a, type: "Debit", amount: 1.0)
        FactoryBot.create(:transaction, source: a, type: "Credit", amount: 2.0)

        a.update_balance
        expect(a.balance).to eq 1.0

        FactoryBot.create(:transaction, source: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0

        FactoryBot.create(:transaction, target: a, type: "Transfer", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 1.0
      end
      it "ignores other accounts debits and credits" do
        a.update_balance
        expect(a.balance).to eq 0

        FactoryBot.create(:transaction, type: "Debit", amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0
      end
      it "ignore pending transactions" do
        a.update_balance
        expect(a.balance).to eq 0

        FactoryBot.create(:transaction,
                           state: "pending",
                           source: a,
                           type: "Debit",
                           amount: 1.0)

        a.update_balance
        expect(a.balance).to eq 0
      end
    end
    describe "with balance check" do
      let!(:bc){ FactoryBot.create(:balance_check, account: a, balance: 13.2, checked_at: 1.minute.ago) }
      it "calculates balance with las balance check as base" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryBot.create(:transaction, type: "Credit", source: a, amount: 1.1)

        a.update_balance
        expect(a.balance).to eq 14.3
      end
      it "ignores transactions before balance checked_at" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryBot.create(:transaction, type: "Credit", source: a, amount: 1.1, transaction_at: bc.checked_at-1.minute)

        a.update_balance
        expect(a.balance).to eq 13.2
      end
      it "ignore pending transactions" do
        a.update_balance
        expect(a.balance).to eq 13.2

        FactoryBot.create(:transaction,
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

        FactoryBot.create(:transaction,
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
