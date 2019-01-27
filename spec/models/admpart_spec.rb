require 'spec_helper'

describe Admpart, :type => :model do

  let(:admpart){  FactoryGirl.create(:admpart) }

  describe "installments_tag_id=" do
    let(:tag){ FactoryGirl.create(:tag, business_id: admpart.business_id) }
    it "sets installments_tag" do
      expect(tag.system_name).to be_nil
      expect(admpart.installments_tag).to be_nil
      admpart.installments_tag_id = tag.id
      expect(tag.reload.system_name).to eq "installment"
      expect(admpart.reload.installments_tag).to eq tag
    end
  end

  describe "sales_tag_id=" do
    let(:tag){ FactoryGirl.create(:tag, business_id: admpart.business_id) }
    it "sets sales_tag" do
      expect(tag.system_name).to be_nil
      expect(admpart.sales_tag).to be_nil
      admpart.sales_tag_id = tag.id
      expect(tag.reload.system_name).to eq "sale"
      expect(admpart.reload.sales_tag).to eq tag
    end
  end

  describe "enrollments_tag_id=" do
    let(:tag){ FactoryGirl.create(:tag, business_id: admpart.business_id) }
    it "sets enrollments_tag" do
      expect(tag.system_name).to be_nil
      expect(admpart.enrollments_tag).to be_nil
      admpart.enrollments_tag_id = tag.id
      expect(tag.reload.system_name).to eq "enrollment"
      expect(admpart.reload.enrollments_tag).to eq tag
    end
  end

  describe "get_for_ref_date" do
    describe "if already created" do
      let!(:admpart){ FactoryGirl.create(:admpart, ref_date: Date.today) }
      it "does nothing" do
        expect{ Admpart.create_for_ref_date(Date.today) }.not_to change{ Admpart.count }
      end
    end
    describe "if no admpart for ref_date" do
      it "creates a new admpart copying previous but with new ref_date" do
        expect{ Admpart.create_for_ref_date(Date.today) }.to change{ Admpart.count }
      end
    end
  end


end
