require 'spec_helper'

RSpec.describe ContactsMerger, :type => :model do
  describe "#merge" do
    let!(:b){FactoryBot.create(:business)}
    let!(:father){FactoryBot.create(:contact, padma_id: 'father', business_id: b.id)}
    let!(:son){FactoryBot.create(:contact, padma_id: 'son', business_id: b.id)}
    let!(:father_membership){FactoryBot.create(:membership, contact_id: father.id, business_id: b.id)}
    let!(:son_membership){FactoryBot.create(:membership, contact_id: son.id, business_id: b.id)}
    let!(:father_sale){FactoryBot.create(:sale, contact_id: father.id, business_id: b.id)}
    let!(:son_sale){FactoryBot.create(:sale, contact_id: son.id, business_id: b.id)}
    before do
      @son_id = son.id
      ContactsMerger.new('son','father').merge
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
