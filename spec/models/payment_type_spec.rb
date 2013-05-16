require 'spec_helper'

describe PaymentType do

  let(:business){FactoryGirl.create(:business)}
  let(:other_business){FactoryGirl.create(:business)}
  let(:payment_type){FactoryGirl.create(:payment_type, business: business)}

  describe "has many memberships and" do
    it { should have_many :memberships }
    it "accepts memberships from it's same business" do
      membership = FactoryGirl.create(:membership, business: business)
      payment_type.memberships = [membership]
      payment_type.should be_valid
    end
    it "rejects memberships from other businesses" do
      membership = FactoryGirl.create(:membership, business: other_business)
      payment_type.memberships = [membership]
      payment_type.should be_invalid
    end
  end

  describe "belongs to a business" do
    it { should belong_to :business }
    it { should validate_presence_of :business }
  end

  describe "has a name" do
    it { should have_db_column :name }
    it { should validate_presence_of :name}
  end

  describe "has a description" do
    it { should have_db_column :description }
  end
end
