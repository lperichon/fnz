require 'rails_helper'

describe InstallmentsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :membership_id => @membership.id,
        :agent_id => @agent.id,
        :due_on => Date.today
    }
  end

  before(:each) do
    @business = FactoryBot.create(:school)
    @membership = FactoryBot.create(:membership, :business => @business)
    @agent = FactoryBot.create(:agent, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET membership installments index" do
    it "assigns all installments as @installments" do
      installment = @membership.installments.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:installments)).to eq([installment])
    end
  end

  describe "GET show" do
    it "should be successful" do
      installment = @membership.installments.create! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param
      expect(response).to be_success
    end

    it "assigns the requested installment as @installment" do
      installment = @membership.installments.create! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param
      expect(assigns(:installment)).to eq installment
    end
  end

  describe "GET new" do
    it "assigns a new installment as @installment" do
      get :new, :business_id => @business.to_param, :membership_id => @membership.to_param
      expect(assigns(:installment)).to be_a_new(Installment)
    end
  end

  describe "GET edit" do
    it "assigns the requested installment as @installment" do
      installment = @membership.installments.create! valid_attributes
      get :edit, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.id
      expect(assigns(:installment)).to eq(installment)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Installment" do
        expect {
          post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => valid_attributes}
        }.to change(Installment, :count).by(1)
      end

      it "assigns a newly created installment as @installment" do
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => valid_attributes}
        expect(assigns(:installment)).to be_a(Installment)
        expect(assigns(:installment)).to be_persisted
      end

      it "redirects to overview" do
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => valid_attributes}
        expect(response).to redirect_to(overview_business_memberships_url(@business))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved installment as @installment" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Installment).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => {}}
        expect(assigns(:installment)).to be_a_new(Installment)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Installment).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested installment" do
        installment = @membership.installments.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Installment).to receive(:update_attributes).with({'value' => 'params'})
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {'value' => 'params'}}
      end

      it "assigns the requested installment as @installment" do
        installment = @membership.installments.create! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => valid_attributes}
        expect(assigns(:installment)).to eq(installment)
      end

      it "redirects to the installment" do
        installment = @membership.installments.create! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => valid_attributes}
        expect(response).to redirect_to(business_installment_url(@business, installment))
      end
    end

    describe "with invalid params" do
      it "assigns the installment as @installment" do
        installment = @membership.installments.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Installment).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {}}
        expect(assigns(:installment)).to eq(installment)
      end

      it "re-renders the 'edit' template" do
        installment = @membership.installments.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Installment).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested installment" do
      installment = @membership.installments.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param}
      }.to change(Installment, :count).by(-1)
    end

    it "redirects to the membership page" do
      installment = @membership.installments.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param}
      expect(response).to redirect_to(business_membership_url(@business, @membership))
    end
  end
end
