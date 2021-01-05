require 'rails_helper'

describe MembershipStats do

  let(:business){FactoryBot.create(:business)}
  
  it "should create a new instance given valid attributes" do
    FactoryBot.build(:membership_stats).should be_valid
  end

  it "should require a business" do
  	FactoryBot.build(:membership_stats, :business => nil).should_not be_valid
  end

  describe "#all_installments" do
    let(:stats){FactoryBot.build(:membership_stats,
                                  business: business,
                                  year: Date.today.year,
                                  month: Date.today.month)}
    before do
      memb = FactoryBot.create(:membership, :business => business)
      @paid_inst = FactoryBot.create(:installment, :membership => memb, :due_on => Date.today)
      tr = FactoryBot.create(:transaction, :type => "Credit", :transaction_at => Date.today, :business => business, :creator => business.owner)
      @paid_inst.trans << tr
      
      memb = FactoryBot.create(:membership, :business => business)
      @unpaid_inst = FactoryBot.create(:installment, :membership => memb, :due_on => Date.today)
    end

    it "sums paid and unpaid installments" do
      expect(BigDecimal.new(stats.all_installments.first['sum'])).to eq (@paid_inst.value+@unpaid_inst.value)
    end
  end

  describe "#paid_installments" do

    describe "with membership_filter" do
      let(:payment_type){FactoryBot.create(:payment_type, business: business)}
      before do
        @membership_stats = FactoryBot.build(:membership_stats, :business => business, :year => Date.today.year, :month => Date.today.month, :membership_filter => ContactSearch.new({ :membership_payment_type_id => [payment_type.id]}))
        @membership = FactoryBot.create(:membership, :business => business, :payment_type_id => nil)
        @installment = FactoryBot.create(:installment, :membership => @membership, :due_on => Date.today)
        @transaction = FactoryBot.create(:transaction, :type => "Credit", :transaction_at => Date.today, :business => business, :creator => business.owner)
        @installment.trans << @transaction
      end
      it "will only consider installmets of memberships matching filter" do
        @membership_stats.paid_installments.first.sum.should be_nil
      end
    end

    describe "with installments that have transactions" do
      before do
        @membership_stats = FactoryBot.build(:membership_stats, :business => business, :year => Date.today.year, :month => Date.today.month)
        @membership = FactoryBot.create(:membership, :business => business)
        @installment = FactoryBot.create(:installment, :membership => @membership, :due_on => Date.today)
        @transaction = FactoryBot.create(:transaction, :type => "Credit", :transaction_at => Date.today, :business => business, :creator => business.owner)
        @installment.trans << @transaction
      end

      it "should return installments" do
        @membership_stats.paid_installments.first.sum.should_not be_nil
      end
    end

    describe "with installments that dont have transactions" do
      before do
        @membership_stats = FactoryBot.build(:membership_stats, :business => business, :year => Date.today.year, :month => Date.today.month)
        @membership = FactoryBot.create(:membership, :business => business)
        @installment = FactoryBot.create(:installment, :membership => @membership, :due_on => Date.today, :status => 'overdue')
      end

      it "should not return installments" do
        expect(@membership_stats.paid_installments.first['sum']).to eq nil
      end
    end
  end

end
