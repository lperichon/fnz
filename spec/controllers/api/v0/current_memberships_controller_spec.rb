require 'spec_helper'

describe Api::V0::CurrentMembershipsController, type: :controller do
  let(:business){ FactoryGirl.create(:business) }
  let(:contacts){ (1..3).map{|i| FactoryGirl.create(:contact, business_id: business.id, padma_id: "padma-#{i}") } }
  describe "GET index" do
    before do
      get :index, app_key: ENV["app_key"],
          business_id: business,
          padma_contact_ids: contacts.map(&:padma_id)
    end
    it "assigns memberships" do
      expect(assigns(:memberships)).not_to be_nil
    end
  end
end
