require 'spec_helper'

describe ProductsController do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :name => "Test Product",
      :price => 3.2,
      :currency => :usd
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all products as @products" do
      product = @business.products.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      assigns(:products).should eq([product])
    end
  end

  describe "GET show" do
    it "should be successful" do
      product = @business.products.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => product.to_param
      response.should be_success
    end

    it "assigns the requested business as @business" do
      product = @business.products.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => product.to_param}
      assigns(:product).should == product
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      assigns(:product).should be_a_new(Product)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      product = @business.products.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => @business.to_param}
      assigns(:product).should eq(product)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Product" do
        expect {
          post :create, {:business_id => @business.to_param, :product => valid_attributes}
        }.to change(Product, :count).by(1)
      end

      it "assigns a newly created product as @products" do
        post :create, {:business_id => @business.to_param, :product => valid_attributes}
        assigns(:product).should be_a(Product)
        assigns(:product).should be_persisted
      end

      it "redirects to the created product" do
        post :create, {:business_id => @business.to_param, :product => valid_attributes}
        response.should redirect_to(business_product_url(@business,Product.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved product as @product" do
        # Trigger the behavior that occurs when invalid params are submitted
        Product.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :product => {}}
        assigns(:product).should be_a_new(Product)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Product.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :product => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested product" do
        product = @business.products.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Product.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :id => product.to_param, :product => {'these' => 'params'}}
      end

      it "assigns the requested product as @product" do
        product = @business.products.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => product.to_param, :product => valid_attributes}
        assigns(:product).should eq(product)
      end

      it "redirects to the product" do
        product = @business.products.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => product.to_param, :product => valid_attributes}
        response.should redirect_to(business_product_url(@business, product))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        product = @business.products.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Product.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => product.to_param, :product => {}}
        assigns(:product).should eq(product)
      end

      it "re-renders the 'edit' template" do
        product = @business.products.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Product.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => product.to_param, :product => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      product = @business.products.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => product.to_param}
      }.to change(Product, :count).by(-1)
    end

    it "redirects to the businesses list" do
      product = @business.products.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => product.to_param}
      response.should redirect_to(business_products_url(@business))
    end
  end

end
