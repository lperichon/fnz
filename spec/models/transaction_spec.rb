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
      :amount => 3.5,
      :transaction_at => 2.days.ago
    }

    User.current_user = @account.business.owner
  end

  describe "transaction rules" do
    let!(:rule){ FactoryGirl.create(:transaction_rule, operator: "contains", value: "hola", contact: FactoryGirl.create(:contact))}
    it "are applied con create, not update" do
      t = FactoryGirl.build(:transaction, description: "hola como te va", business: rule.business, contact_id: nil)
      t.save
      expect(t.reload.contact_id).not_to be_nil
      expect(t.reload.contact_id).to eq rule.contact_id
      t.contact_id = nil
      t.save
      expect(t.reload.contact_id).to be_nil
    end
  end

  it "unsets target when changing FROM transfer" do
    t = FactoryGirl.create(:transaction, type: "Transfer", target: @account)
    expect(t.target).to eq @account
    t.type = "Debit"
    t.save
    expect(t.target).to be_nil
    expect(Transaction.find(t.id).target).to be_nil

    t = FactoryGirl.create(:transaction, type: "Transfer", target: @account)
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

  it "should import from uncomplete csv row" do
    transaction = Transaction.build_from_csv(@account.business, [@account.name, Date.today, "2.1", "Test import transaction"])
    transaction.should be_valid
  end

  it "should import from complete csv row" do
    FactoryGirl.create(:agent, business_id: @account.business.id)
    FactoryGirl.create(:contact, business_id: @account.business.id)

    transaction = Transaction.build_from_csv(@account.business, [@account.name, Date.today, "2.1", "Test import transaction", @account.business.agents.enabled.first.name, @account.business.contacts.first.name])
    transaction.should be_valid
  end

  describe "installments automagick" do
    let(:transaction){ FactoryGirl.build(:transaction, contact_id: nil, agent_id: nil) }
    let(:contact){ FactoryGirl.create(:contact, business_id: transaction.business_id) }
    let(:admpart_tag){ FactoryGirl.create(:tag, business_id: transaction.business_id, system_name: "installment") }

    describe "linked to an installment" do
      let(:installment){ FactoryGirl.create(:installment, membership: FactoryGirl.create(:membership, business_id: transaction.business_id, contact_id: contact.id ) ) }
      before do
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
      @account.balance.should eq(@credit.amount)
    end

    it "should re calculate account balances on update" do
      @credit.amount = 5
      @credit.save
      @account.reload
      @account.balance.should eq(@credit.amount)
    end
  end

  context "updating an existing transaction to a transfer" do
    before(:each) do
      @target = FactoryGirl.create(:account, :business => @account.business)
      @credit = Credit.create!(@attr)
    end

    it "should re calculate account balances on update" do
      @credit.update_attributes(type: "Transfer", target_id: @target.id)
      @target.reload
      @target.balance.should eq(@credit.amount)
    end
  end

  context "untagged" do
    before(:each) do
      @untagged_credit = Credit.create!(@attr)
    end
    it "should scope untagged transactions" do
      Credit.untagged.count.should == 1
    end
  end

  context "#build_from_csv" do
  	before do
  		@business = FactoryGirl.create(:business)
  	end
  	it "should consider status column" do
  		new_transaction = Transaction.build_from_csv(@business, ['test','1983-03-03', '2.3', 'Testing', 'tag', nil, nil, 'pending'])
  		new_transaction.state.should eq("pending")
  	end
  end

  context "#report_at" do
    before do
      @transaction = Debit.create!(@attr)
    end

    it "should default to transaction_at value" do
      @transaction.report_at.should eq(@transaction.transaction_at)
    end
  end
end
