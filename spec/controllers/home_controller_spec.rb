require 'spec_helper'

describe HomeController, :type => :controller do

  before(:each) do
    @school = FactoryGirl.create(:school)
    sign_in @school.owner
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should redirect_to(overview_business_memberships_path(:business_id => "test"))
    end
  end

end
