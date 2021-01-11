require 'rails_helper'

describe SalesController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
        :business_id => @business.id,
        :contact_id => @contact.id,
        :agent_id => @agent.id,
        :sold_on => Date.today
    }
  end

  before(:each) do
    @business = FactoryBot.create(:school)
    @contact = FactoryBot.create(:contact, :business => @business)
    @agent = FactoryBot.create(:agent, :business => @business)
    @user = @business.owner
    sign_in @user
  end

  describe "GET business sales index" do
    it "assigns all sales as @sales" do
      sale = @business.sales.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:sales)).to eq([sale])
    end
  end

  describe "GET show" do
    it "should be successful" do
      sale = @business.sales.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => sale.to_param
      expect(response).to be_success
    end

    it "assigns the requested sale as @sale" do
      sale = @business.sales.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => sale.to_param
      expect(assigns(:sale)).to eq sale
    end
  end

  describe "GET new" do
    it "assigns a new sale as @sale" do
      get :new, :business_id => @business.to_param
      expect(assigns(:sale)).to be_a_new(Sale)
    end
  end

  describe "GET edit" do
    it "assigns the requested sale as @sale" do
      sale = @business.sales.create! valid_attributes
      get :edit, :business_id => @business.to_param, :id => sale.to_param
      expect(assigns(:sale)).to eq(sale)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Sale" do
        expect {
          post :create, {:business_id => @business.to_param, :sale => valid_attributes}
        }.to change(Sale, :count).by(1)
      end

      it "assigns a newly created sale as @sale" do
        post :create, {:business_id => @business.to_param, :sale => valid_attributes}
        expect(assigns(:sale)).to be_a(Sale)
        expect(assigns(:sale)).to be_persisted
      end

      it "assigns the current user to the created sale as creator" do
        post :create, {:business_id => @business.to_param, :sale => valid_attributes}
      end

      it "redirects to the created sale" do
        post :create, {:business_id => @business.to_param, :sale => valid_attributes}
        expect(response).to redirect_to(business_sale_url(@business, Sale.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sale as @sale" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sale).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :sale => {}}
        expect(assigns(:sale)).to be_a_new(Sale)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sale).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :sale => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sale" do
        sale = @business.sales.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Sale).to receive(:update_attributes).with({'contact_id' => 'params'})
        put :update, {:business_id => @business.to_param, :id => sale.to_param, :sale => {'contact_id' => 'params'}}
      end

      it "assigns the requested sale as @sale" do
        sale = @business.sales.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => sale.to_param, :sale => valid_attributes}
        expect(assigns(:sale)).to eq(sale)
      end

      it "redirects to the sale" do
        sale = @business.sales.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => sale.to_param, :sale => valid_attributes}
        expect(response).to redirect_to(business_sale_url(@business, sale))
      end
    end

    describe "with invalid params" do
      it "assigns the sale as @sale" do
        sale = @business.sales.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sale).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => sale.to_param, :sale => {}}
        expect(assigns(:sale)).to eq(sale)
      end

      it "re-renders the 'edit' template" do
        sale = @business.sales.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Sale).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => sale.to_param, :sale => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested sale" do
      sale = @business.sales.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => sale.to_param}
      }.to change(Sale, :count).by(-1)
    end

    it "redirects to the businesses list" do
      sale = @business.sales.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => sale.to_param}
      expect(response).to redirect_to(business_sales_url(@business))
    end
  end

end
