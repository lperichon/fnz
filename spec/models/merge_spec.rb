require 'spec_helper'

RSpec.describe Merge, :type => :model do
  describe "#merge" do
    let!(:b){FactoryGirl.create(:business)}
    let!(:father){FactoryGirl.create(:contact, padma_id: 'father', business_id: b.id)}
    let!(:son){FactoryGirl.create(:contact, padma_id: 'son', business_id: b.id)}
    let!(:father_membership){FactoryGirl.create(:membership, contact_id: father.id, business_id: b.id)}
    let!(:son_membership){FactoryGirl.create(:membership, contact_id: son.id, business_id: b.id)}
    let!(:father_sale){FactoryGirl.create(:sale, contact_id: father.id, business_id: b.id)}
    let!(:son_sale){FactoryGirl.create(:sale, contact_id: son.id, business_id: b.id)}
    before do
      @son_id = son.id
      Merge.new('son','father').merge
    end
    it "destroys son" do
      expect{Contact.find(@son_id)}.to raise_exception(ActiveRecord::RecordNotFound)
    end
    it "moves membership from son to father" do
      expect(father.reload.memberships).to include son_membership
    end
    it "moves sales from son to father" do
      expect(father.reload.sales).to include son_sale
    end
    it "preserves father's memberships" do
      expect(father.reload.memberships).to include father_membership
    end
    it "preserves fathers's sales" do
      expect(father.reload.sales).to include father_sale
    end
  end
end
