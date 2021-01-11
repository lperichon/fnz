require 'rails_helper'

describe HomeController, :type => :controller do

  before(:each) do
    @school = FactoryBot.create(:school)
    sign_in @school.owner
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      expect(response).to redirect_to(overview_business_memberships_path(:business_id => "test"))
    end
  end

end
