require 'rails_helper'

describe BusinessesController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :name => "Test Business",
      :type => "Personal"}
  end

  before(:each) do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  describe "GET index" do
    it "assigns all businesses as @businesses" do
      @user.owned_businesses.create! valid_attributes
      business = Business.last

      get :index, {}
      expect(assigns(:businesses).map(&:id)).to eq([business].map(&:id))
    end
  end

  describe "GET show" do
    it "should be successful" do
      business = @user.owned_businesses.create! valid_attributes
      get :show, :id => business.id
      expect(response).to be_success
    end

    it "assigns the requested business as @business" do
      @user.owned_businesses.create! valid_attributes
      business = Business.last
      get :show, {:id => business.to_param}
      expect(assigns(:business)).to eq business
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {}
      expect(assigns(:business)).to be_a_new(Business)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      @user.owned_businesses.create! valid_attributes
      business = Business.last

      get :edit, {:id => business.to_param}
      expect(assigns(:business)).to eq(business)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Business" do
        expect {
          post :create, {:business => valid_attributes}
        }.to change(Business, :count).by(1)
      end

      it "assigns a newly created business as @business" do
        post :create, {:business => valid_attributes}
        expect(assigns(:business)).to be_a(Business)
        expect(assigns(:business)).to be_persisted
      end

      it "redirects to the created business" do
        post :create, {:business => valid_attributes}
        expect(response).to redirect_to(business_path(Business.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved business as @business" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Business).to receive(:save).and_return(false)
        post :create, {:business => {}}
        expect(assigns(:business)).to be_a_new(Business)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Business).to receive(:save).and_return(false)
        post :create, {:business => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested business" do
        business = @user.owned_businesses.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Business).to receive(:update_attributes).with({'name' => 'params'})
        put :update, {:id => business.to_param, :business => {'name' => 'params'}}
      end

      it "assigns the requested business as @business" do
        @user.owned_businesses.create! valid_attributes
        business = Business.last
        put :update, {:id => business.to_param, :business => valid_attributes}
        expect(assigns(:business)).to eq(business)
      end

      it "redirects to the business" do
        business = @user.owned_businesses.create! valid_attributes
        put :update, {:id => business.to_param, :business => valid_attributes}
        expect(response).to redirect_to(business_path(business))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        @user.owned_businesses.create! valid_attributes
        business = Business.last
            # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Business).to receive(:save).and_return(false)
        put :update, {:id => business.to_param, :business => {}}
        expect(assigns(:business)).to eq(business)
      end

      it "re-renders the 'edit' template" do
        business = @user.owned_businesses.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Business).to receive(:save).and_return(false)
        put :update, {:id => business.to_param, :business => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      business = @user.owned_businesses.create! valid_attributes
      expect {
        delete :destroy, {:id => business.to_param}
      }.to change(Business, :count).by(-1)
    end

    it "redirects to the businesses list" do
      business = @user.owned_businesses.create! valid_attributes
      delete :destroy, {:id => business.to_param}
      expect(response).to redirect_to(businesses_url)
    end
  end

end
