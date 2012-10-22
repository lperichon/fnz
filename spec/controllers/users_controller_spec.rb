require 'spec_helper'

describe UsersController do

  before (:each) do
    @business = FactoryGirl.create(:business)
    sign_in @business.owner
  end

  describe "GET 'index'" do
    
    it "should be successful" do
      get :index, :business_id => @business.to_param
      response.should be_success
    end
    
  end

  describe "POST 'create'" do
    before do
      @user2 = FactoryGirl.create(:user, :email => 'example2@example.com')
    end

    it "should be successful" do
      post :create, :business_id => @business.to_param, :user => {:email => @user2.email}
      response.should be_success
    end

    it "should add the user to the business" do
      post :create, :business_id => @business.to_param, :user => {:email => @user2.email}
      @business.reload
      @business.users.should include(@user2)
    end

  end

  describe "DELETE 'delete'" do
    before do
      @user2 = FactoryGirl.create(:user, :email => 'example2@example.com')
      @business.users << @user2
    end

    it "should be successful" do
      delete :destroy, :business_id => @business.to_param, :id => @user2.to_param
      response.should be_success
    end

    it "should remove the user from the business" do
      delete :destroy, :business_id => @business.to_param, :id => @user2.to_param
      @business.reload
      @business.users.should_not include(@user2)
    end

  end

end
