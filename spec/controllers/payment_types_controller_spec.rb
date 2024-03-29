require 'rails_helper'

describe PaymentTypesController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :name => "Test PaymentType",
        :description => "asdlfajsdlfa s"
    }
  end

  before(:each) do
    @business = FactoryBot.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all payment_types as @payment_types" do
      payment_type = @business.payment_types.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:payment_types)).to eq([payment_type])
    end
  end

  describe "GET show" do
    it "should be successful" do
      payment_type = @business.payment_types.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => payment_type.to_param
      expect(response).to be_success
    end

    it "assigns the requested business as @business" do
      payment_type = @business.payment_types.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => payment_type.to_param}
      expect(assigns(:payment_type)).to eq payment_type
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      expect(assigns(:payment_type)).to be_a_new(PaymentType)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      payment_type = @business.payment_types.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => payment_type.to_param}
      expect(assigns(:payment_type)).to eq(payment_type)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PaymentType" do
        expect {
          post :create, {:business_id => @business.to_param, :payment_type => valid_attributes}
        }.to change(PaymentType, :count).by(1)
      end

      it "assigns a newly created payment_type as @payment_types" do
        post :create, {:business_id => @business.to_param, :payment_type => valid_attributes}
        expect(assigns(:payment_type)).to be_a(PaymentType)
        expect(assigns(:payment_type)).to be_persisted
      end

      it "redirects to payment_types index" do
        post :create, {:business_id => @business.to_param, :payment_type => valid_attributes}
        expect(response).to redirect_to(business_payment_types_url(@business))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved payment_type as @payment_type" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(PaymentType).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :payment_type => {}}
        expect(assigns(:payment_type)).to be_a_new(PaymentType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(PaymentType).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :payment_type => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested payment_type" do
        payment_type = @business.payment_types.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(PaymentType).to receive(:update_attributes).with({'name' => 'params'})
        put :update, {:business_id => @business.to_param, :id => payment_type.to_param, :payment_type => {'name' => 'params'}}
      end

      it "assigns the requested payment_type as @payment_type" do
        payment_type = @business.payment_types.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => payment_type.to_param, :payment_type => valid_attributes}
        expect(assigns(:payment_type)).to eq(payment_type)
      end

      it "redirects to the payment_types index" do
        payment_type = @business.payment_types.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => payment_type.to_param, :payment_type => valid_attributes}
        expect(response).to redirect_to(business_payment_types_url(@business))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        payment_type = @business.payment_types.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(PaymentType).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => payment_type.to_param, :payment_type => {}}
        expect(assigns(:payment_type)).to eq(payment_type)
      end

      it "re-renders the 'edit' template" do
        payment_type = @business.payment_types.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(PaymentType).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => payment_type.to_param, :payment_type => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      payment_type = @business.payment_types.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => payment_type.to_param}
      }.to change(PaymentType, :count).by(-1)
    end

    it "redirects to the businesses list" do
      payment_type = @business.payment_types.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => payment_type.to_param}
      expect(response).to redirect_to(business_payment_types_url(@business))
    end
  end

end
