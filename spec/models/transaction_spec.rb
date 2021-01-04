require 'spec_helper'

describe Transaction do
  
  before(:each) do
    class Debit < Transaction

    end

    @account = FactoryBot.create(:account)
    @attr = {
      :description => "Example Transaction",
      :business_id => @account.business.id,
      :source_id => @account.id,
      :amount => 3.5,
      :transaction_at => 2.days.ago
    }

    User.current_user = @account.business.owner
  end

  describe "currencies" do
    let(:business){ FactoryBot.create(:business, currency_code: "ars") }
    let(:acc){ FactoryBot.create(:account, currency: "ars", business: business) }
    let(:other_currency_account){ FactoryBot.create(:account, currency: "usd", business: business) }
    it "allows tranaction on account on businessses currency" do
      t = FactoryBot.build(:transaction, source: acc)
      expect(t).to be_valid
    end
    it "allow TAGGED transaction on businesses currency" do
      t = FactoryBot.create(:transaction, source: acc)
      t.tags << FactoryBot.create(:tag, business: business)
      expect(t).to be_valid
    end
    it "allows not-tagged transactions on other currencies" do
      t = FactoryBot.build(:transaction, source: other_currency_account)
      expect(t).to be_valid
    end
    it "wont allow to TAG Debit or Credit not in Business currency" do
      t = FactoryBot.create(:transaction, source: other_currency_account)
      t.tags << FactoryBot.create(:tag, business: business)
      expect(t).not_to be_valid
    end
  end

  describe "transaction rules" do
    let!(:rule){ FactoryBot.create(:transaction_rule, operator: "contains", value: "hola", contact: FactoryBot.create(:contact))}
    it "are applied con create, not update" do
      expect(rule).to be_valid
      t = FactoryBot.build(:transaction, description: "hola como te va", business: rule.business, contact_id: nil)
      t.save
      expect(t.reload.contact_id).not_to be_nil
      expect(t.reload.contact_id).to eq rule.contact_id
      t.contact_id = nil
      t.save
      expect(t.reload.contact_id).to be_nil
    end
  end

  it "unsets target when changing FROM transfer" do
    t = FactoryBot.create(:transaction, type: "Transfer", target: @account)
    expect(t.target).to eq @account
    t.type = "Debit"
    t.save
    expect(t.target).to be_nil
    expect(Transaction.find(t.id).target).to be_nil

    t = FactoryBot.create(:transaction, type: "Transfer", target: @account)
    expect(t.target).to eq @account
    t.amount = 10
    t.save
    expect(t.target).to eq @account
    expect(Transaction.find(t.id).target).to eq @account
  end

  it "should create a new instance given a valid attribute" do
    Debit.create!(@attr)
  end
  
  it "should require a description" do
    no_desc_transaction = Transaction.new(@attr.merge(:description => ""))
    expect(no_desc_transaction).not_to be_valid
  end

  it "should require an amount" do
    no_amount_transaction = Transaction.new(@attr.merge(:amount => ""))
    expect(no_amount_transaction).not_to be_valid
  end

  it "should require a positive amount" do
    negative_amount_transaction = Transaction.new(@attr.merge(:amount => -10.5))
    expect(negative_amount_transaction).not_to be_valid
  end

  it "should set the business based on the source account" do
    no_business_transaction = Transaction.new(@attr.merge(:business_id => nil))
    expect(no_business_transaction).to be_valid
  end

  it "should require a source account" do
    no_source_transaction = Transaction.new(@attr.merge(:source_id => nil))
    expect(no_source_transaction).not_to be_valid
  end

  it "should import from uncomplete csv row" do
    transaction = Transaction.build_from_csv(@account.business, [@account.name, Date.today, "2.1", "Test import transaction"])
    expect(transaction).to be_valid
  end

  it "should import from complete csv row" do
    FactoryBot.create(:agent, business_id: @account.business.id)
    FactoryBot.create(:contact, business_id: @account.business.id)

    transaction = Transaction.build_from_csv(@account.business, [@account.name, Date.today, "2.1", "Test import transaction", @account.business.agents.enabled.first.name, @account.business.contacts.first.name])
    expect(transaction).to be_valid
  end

  describe "installments automagick" do
    let(:transaction){ FactoryBot.build(:transaction, contact_id: nil, agent_id: nil) }
    let(:contact){ FactoryBot.create(:contact, business_id: transaction.business_id) }
    let(:admpart_tag){ FactoryBot.create(:tag, business_id: transaction.business_id, system_name: "installment") }

    describe "linked to an installment" do
      let(:installment){ FactoryBot.create(:installment, membership: FactoryBot.create(:membership, business_id: transaction.business_id, contact_id: contact.id ) ) }
      before do
        # invoke admpart_tag for it to be available
        # I tried putting let!(:admpart_tag) for it to be invoked, but it did not work
        # If this is not done admpart_id will not exist until admpart_tag.id is called
        admpart_tag
        transaction.installments << installment
        transaction.save
      end
      it "sets contact_id and agent_id" do
        expect(transaction.agent_id).to eq installment.agent_id
        expect(transaction.contact_id).to eq installment.membership.contact_id
      end
      it "tags as installment" do
        expect(transaction.reload.admpart_tag_id).to eq admpart_tag.id
      end
    end

    describe "if tagged as installment" do
      it "links available installment"
    end
  end


  context "updating an existing transaction" do
    before(:each) do
      @credit = Credit.create!(@attr)
    end

    it "should calculate account balance on create" do
      @account.reload
      expect(@account.balance).to eq(@credit.amount)
    end

    it "should re calculate account balances on update" do
      @credit.amount = 5
      @credit.save
      @account.reload
      expect(@account.balance).to eq(@credit.amount)
    end
  end

  context "updating an existing transaction to a transfer" do
    before(:each) do
      @target = FactoryBot.create(:account, :business => @account.business)
      @credit = Credit.create!(@attr)
    end

    it "should re calculate account balances on update" do
      @credit.update_attributes(type: "Transfer", target_id: @target.id)
      @target.reload
      expect(@target.balance).to eq(@credit.amount)
    end
  end

  context "untagged" do
    before(:each) do
      @untagged_credit = Credit.create!(@attr)
    end
    it "should scope untagged transactions" do
      expect(Credit.untagged.count).to eq 1
    end
  end

  context "#build_from_csv" do
  	before do
  		@business = FactoryBot.create(:business)
  	end
  	it "should consider status column" do
  		new_transaction = Transaction.build_from_csv(@business, ['test','1983-03-03', '2.3', 'Testing', 'tag', nil, nil, 'pending'])
  expect(		new_transaction.state).to eq("pending")
  	end
  end

  context "#report_at" do
    before do
      @transaction = Debit.create!(@attr)
    end

    it "should default to transaction_at value" do
      expect(@transaction.report_at.to_date).to eq(@transaction.transaction_at.to_date)
    end
  end
end
