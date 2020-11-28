require 'spec_helper'

describe Membership do
  
  before(:each) do
    @business = FactoryBot.create(:business)
    @contact = FactoryBot.create(:contact, :business => @business)
    @attr = {
      :contact_id => @contact.id,
      :business_id => @business.id,
      :begins_on => Date.today.beginning_of_month,
      :ends_on => 11.months.from_now.end_of_month,
      :monthly_due_day => 10,
      :value => 100
    }
  end

  it { should have_db_column :name }

  describe "creating without :create_monthly_installments" do
    it "wont create installments" do
      m = FactoryBot.build(:membership)
      expect{ m.save }.not_to change{ Installment.count }
    end
  end
  describe "creating with :create_monthly_installments flag" do
    it "creates monthly installments of membership value" do
      m = FactoryBot.build(:membership,
                            create_monthly_installments: true,
                            begins_on: Date.today.beginning_of_month,
                            ends_on:   11.months.from_now.end_of_month
                           )
      expect{ m.save }.to change{ Installment.count }.by 12
    end
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
    Membership.create!(@attr)
  end
  

  it "should require a business" do
    no_business_membership = Membership.new(@attr.merge(:business_id => nil))
    no_business_membership.should_not be_valid
  end


  it "should require a contact" do
    no_contact_membership = Membership.new(@attr.merge(:contact_id => nil))
    no_contact_membership.should_not be_valid
  end

  it "should require a starting date" do
    no_start_membership = Membership.new(@attr.merge(:begins_on => nil))
    no_start_membership.should_not be_valid
  end

  it "should require an ending date" do
    no_end_membership = Membership.new(@attr.merge(:ends_on => nil))
    no_end_membership.should_not be_valid
  end

  it "should require an ending date after the starting date" do
    date_conflict_membership = Membership.new(@attr.merge(:ends_on => 10.years.ago))
    date_conflict_membership.should_not be_valid
  end

  it "should set the contacts current_membership after create" do
  	@membership = Membership.create(@attr)
  	@contact.reload
  	@contact.current_membership.should eq(@membership)
  end


  describe "closing a membership" do
  	before do
  		@membership = Membership.create(@attr)
  		@membership.closed_on = Date.today
  		@membership.save
  		@contact.reload
  	end

  	it "should set the contacts current_membership to nil" do
  		@contact.current_membership.should be_nil
  	end
  end
end
