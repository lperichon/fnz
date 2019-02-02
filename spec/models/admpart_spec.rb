require 'spec_helper'

describe Admpart, :type => :model do

  let(:admpart){  FactoryGirl.create(:admpart) }

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
