require 'spec_helper'

describe Api::V0::CurrentMembershipsController, type: :controller do
  let(:business){ FactoryBot.create(:school, padma_id: 'test') }
  let(:contacts){ (1..3).map{|i| FactoryBot.create(:contact, business_id: business.id, padma_id: "padma-#{i}") } }
  let!(:membership){ FactoryBot.create(:membership, business: business, contact: contacts[0]) }
  describe "GET index" do
    before do
      get :index, app_key: ENV["app_key"],
          business_id: business.padma_id,
          padma_contact_ids: contacts.map(&:padma_id)
    end
    it "assigns memberships" do
      expect(assigns(:memberships)).not_to be_nil
    end
    it "assigns json" do
      membership.reload
      expect(assigns(:json).to_json).to eq [
        {
          value: membership.value,
          begins_on: membership.begins_on,
          ends_on: membership.ends_on,
          payment_type: membership.payment_type.name,
          padma_contact_id: membership.contact.padma_id,
          name: membership.name,
          installments: []
        }
      ].to_json
    end
  end
end
