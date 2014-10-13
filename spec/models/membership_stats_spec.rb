require 'spec_helper'

describe MembershipStats do
  
  it "should create a new instance given valid attributes" do
    FactoryGirl.build(:membership_stats).should be_valid
  end

  it "should require a business" do
  	FactoryGirl.build(:membership_stats, :business => nil).should_not be_valid
  end

  describe "with membership_filter" do
    let(:business){FactoryGirl.create(:business)}
    let(:payment_type){FactoryGirl.create(:payment_type, business: business)}
    before do
  		@membership_stats = FactoryGirl.build(:membership_stats, :business => business, :year => Date.today.year, :month => Date.today.month, :membership_filter => { :payment_type_id => payment_type.id})
  		@membership = FactoryGirl.create(:membership, :business => business, :payment_type_id => nil)
  		@installment = FactoryGirl.create(:installment, :membership => @membership, :due_on => Date.today)
  		@transaction = FactoryGirl.create(:transaction, :type => "Credit", :transaction_at => Date.today, :business => business, :creator => business.owner)
  		@installment.transactions << @transaction
    end
    it "will only consider installmets of memberships matching filter" do
    	@membership_stats.installments.first.sum.should be_nil
    end
  end

  describe "with installments that have transactions" do
  	before do
  		@business = FactoryGirl.create(:school)
  		@membership_stats = FactoryGirl.build(:membership_stats, :business => @business, :year => Date.today.year, :month => Date.today.month)
  		@membership = FactoryGirl.create(:membership, :business => @business)
  		@installment = FactoryGirl.create(:installment, :membership => @membership, :due_on => Date.today)
  		@transaction = FactoryGirl.create(:transaction, :type => "Credit", :transaction_at => Date.today, :business => @business, :creator => @business.owner)
  		@installment.transactions << @transaction
  	end

    it "should return installments" do
    	@membership_stats.installments.first.sum.should_not be_nil
    end
  end

  describe "with installments that dont have transactions" do
  	before do
  		@business = FactoryGirl.create(:school)
  		@membership_stats = FactoryGirl.build(:membership_stats, :business => @business, :year => Date.today.year, :month => Date.today.month)
  		@membership = FactoryGirl.create(:membership, :business => @business)
  		@installment = FactoryGirl.create(:installment, :membership => @membership, :due_on => Date.today)
  	end

    it "should not return installments" do
    	@membership_stats.installments.first.sum.should be_nil
    end
  end
end
