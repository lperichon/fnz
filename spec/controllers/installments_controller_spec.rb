require 'spec_helper'

describe InstallmentsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :membership_id => @membership.id,
        :due_on => Date.today
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:school)
    @membership = FactoryGirl.create(:membership, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET membership installments index" do
    it "assigns all installments as @installments" do
      installment = @membership.installments.create! valid_attributes
      get :index, {:business_id => @business.to_param, :membership_id => @membership.to_param}
      assigns(:installments).should eq([installment])
    end
  end

  describe "GET show" do
    it "should be successful" do
      installment = @membership.installments.create! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param
      response.should be_success
    end

    it "assigns the requested installment as @installment" do
      installment = @membership.installments.create! valid_attributes
      get :show, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param
      assigns(:installment).should == installment
    end
  end

  describe "GET new" do
    it "assigns a new installment as @installment" do
      get :new, :business_id => @business.to_param, :membership_id => @membership.to_param
      assigns(:installment).should be_a_new(Installment)
    end
  end

  describe "GET edit" do
    it "assigns the requested installment as @installment" do
      installment = @membership.installments.create! valid_attributes
      get :edit, :business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.id
      assigns(:installment).should eq(installment)
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
        assigns(:installment).should be_a(Installment)
        assigns(:installment).should be_persisted
      end

      it "redirects to the created installment" do
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => valid_attributes}
        response.should redirect_to(business_membership_installment_url(@business, @membership, Installment.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved installment as @installment" do
        # Trigger the behavior that occurs when invalid params are submitted
        Installment.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => {}}
        assigns(:installment).should be_a_new(Installment)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Installment.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :membership_id => @membership.to_param, :installment => {}}
        response.should render_template("new")
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
        Installment.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {'these' => 'params'}}
      end

      it "assigns the requested installment as @installment" do
        installment = @membership.installments.create! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => valid_attributes}
        assigns(:installment).should eq(installment)
      end

      it "redirects to the installment" do
        installment = @membership.installments.create! valid_attributes
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => valid_attributes}
        response.should redirect_to(business_membership_installment_url(@business, @membership, installment))
      end
    end

    describe "with invalid params" do
      it "assigns the installment as @installment" do
        installment = @membership.installments.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Installment.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {}}
        assigns(:installment).should eq(installment)
      end

      it "re-renders the 'edit' template" do
        installment = @membership.installments.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Installment.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param, :installment => {}}
        response.should render_template("edit")
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

    it "redirects to the installments list" do
      installment = @membership.installments.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :membership_id => @membership.to_param, :id => installment.to_param}
      response.should redirect_to(business_membership_installments_url(@business, @membership))
    end
  end
end
