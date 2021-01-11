require 'rails_helper'

describe UsersController, :type => :controller do

  before (:each) do
    @business = FactoryBot.create(:business)
    sign_in @business.owner
  end

  describe "GET 'index'" do
    
    it "should be successful" do
      get :index, :business_id => @business.to_param
      expect(response).to be_success
    end
    
  end

  describe "POST 'create'" do
    before do
      @user2 = FactoryBot.create(:user, :email => 'example2@example.com')
    end

    it "should be successful" do
      post :create, :business_id => @business.to_param, :user => {:email => @user2.email}
      expect(response).to be_redirect
    end

    it "should add the user to the business" do
      post :create, :business_id => @business.to_param, :user => {:email => @user2.email}
      @business.reload
      expect(@business.users).to include(@user2)
    end

  end

  describe "DELETE 'delete'" do
    before do
      @user2 = FactoryBot.create(:user, :email => 'example2@example.com')
      @business.users << @user2
    end

    it "should be successful" do
      delete :destroy, :business_id => @business.to_param, :id => @user2.to_param
      expect(response).to be_redirect
    end

    it "should remove the user from the business" do
      delete :destroy, :business_id => @business.to_param, :id => @user2.to_param
      @business.reload
      expect(@business.users).not_to include(@user2)
    end

  end

end
