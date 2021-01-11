require 'rails_helper'

describe InscriptionsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :contact_id => @contact.id,
        :business_id => @business.id,
        :value => 100
    }
  end

  before(:each) do
    @business = FactoryBot.create(:event)
    @contact = FactoryBot.create(:contact, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET business memberships index" do
    it "assigns all memberships as @memberships" do
      inscription = @business.inscriptions.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:inscriptions)).to include inscription
    end
  end

  describe "GET show" do
    it "should be successful" do
      inscription = @business.inscriptions.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => inscription.to_param
      expect(response).to be_success
    end

    it "assigns the requested inscription as @inscription" do
      inscription = @business.inscriptions.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => inscription.to_param
      expect(assigns(:inscription)).to eq inscription
    end
  end

  describe "GET new" do
    it "assigns a new inscription as @inscription" do
      get :new, :business_id => @business.to_param
      expect(assigns(:inscription)).to be_a_new(Inscription)
    end
  end

  describe "GET edit" do
    it "assigns the requested inscription as @inscription" do
      inscription = @business.inscriptions.create! valid_attributes
      get :edit, :business_id => @business.to_param, :id => inscription.to_param
      expect(assigns(:inscription)).to eq(inscription)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new inscription" do
        expect {
          post :create, {:business_id => @business.to_param, :inscription => valid_attributes}
        }.to change(Inscription, :count).by(1)
      end

      it "assigns a newly created inscription as @inscription" do
        post :create, {:business_id => @business.to_param, :inscription => valid_attributes}
        expect(assigns(:inscription)).to be_a(Inscription)
        expect(assigns(:inscription)).to be_persisted
      end

      it "redirects to the inscriptions list" do
        post :create, {:business_id => @business.to_param, :inscription => valid_attributes}
        expect(response).to redirect_to(business_inscriptions_url(@business))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved inscription as @inscription" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Inscription).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :inscription => {}}
        expect(assigns(:inscription)).to be_a_new(Inscription)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Inscription).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :inscription => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested inscription" do
        inscription = @business.inscriptions.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Inscription).to receive(:update_attributes).with({'value' => 'params'})
        put :update, {:business_id => @business.to_param, :id => inscription.to_param, :inscription => {'value' => 'params'}}
      end

      it "assigns the requested inscription as @inscription" do
        inscription = @business.inscriptions.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => inscription.to_param, :inscription => valid_attributes}
        expect(assigns(:inscription)).to eq(inscription)
      end

      it "redirects to the inscription" do
        inscription = @business.inscriptions.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => inscription.to_param, :inscription => valid_attributes}
        expect(response).to redirect_to(edit_business_inscription_url(@business, inscription))
      end
    end

    describe "with invalid params" do
      it "assigns the inscription as @inscription" do
        inscription = @business.inscriptions.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Inscription).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => inscription.to_param, :inscription => {}}
        expect(assigns(:inscription)).to eq(inscription)
      end

      it "re-renders the 'edit' template" do
        inscription = @business.inscriptions.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Inscription).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => inscription.to_param, :inscription => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested inscription" do
      inscription = @business.inscriptions.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => inscription.to_param}
      }.to change(Inscription, :count).by(-1)
    end

    it "redirects to the businesses list" do
      inscription = @business.inscriptions.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => inscription.to_param}
      expect(response).to redirect_to(business_inscriptions_url(@business))
    end
  end

end
