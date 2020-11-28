require 'spec_helper'

describe Inscription do
  
  before(:each) do
    @business = FactoryBot.create(:event)
    @contact = FactoryBot.create(:contact, :business => @business)
    @attr = {
      :contact_id => @contact.id,
      :business_id => @business.id,
      :value => 100
    }
  end

  describe "has a payment type" do
    it {should belong_to :payment_type }
    it "nullify association if payment is destroyed" do
      pt = FactoryBot.create(:payment_type, business: @business)
      membership = FactoryBot.create(:membership, business: @business, payment_type: pt)
      membership.payment_type.should == pt
      pt.destroy
      membership.reload.payment_type.should be_nil
    end
  end

  it "should create a new instance given a valid attribute" do
    Inscription.create!(@attr)
  end
  
  it "should require a business" do
    no_business_inscription = Inscription.new(@attr.merge(:business_id => nil))
    no_business_inscription.should_not be_valid
  end

  it "should require a contact" do
    no_contact_inscription = Inscription.new(@attr.merge(:contact_id => nil))
    no_contact_inscription.should_not be_valid
  end

  describe "#balance" do
    before do
      @inscription = FactoryBot.create(:inscription, :business => @business)
    end
    
    it "should be 0 to begin" do
      @inscription.balance.should eq(0)
    end

    describe "when there is one completed transaction" do
      before do
        source_account = FactoryBot.create(:account, :business => @business)
        @transaction = FactoryBot.create(:transaction, :type => "Credit", :business => @business, :source => source_account, :creator => @business.owner, :transaction_at => Date.today)
        @inscription.transactions << @transaction
        @inscription.reload
      end

      it "should calculate the balance" do
        @inscription.balance.should eq(@transaction.amount)
      end

      describe "and it is updated" do
        before do
          @transaction.amount = 99
          @transaction.save
          @inscription.reload
        end

        it "should recalculate the inscriptions's balance" do
          @inscription.balance.should eq(@transaction.amount)
        end
      end
    end
  end
end
