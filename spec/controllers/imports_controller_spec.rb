require 'spec_helper'

describe ImportsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :upload => fixture_file_upload('/empty_transactions.csv', 'text/csv')
    }
  end

  before(:each) do
    @business = FactoryGirl.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all imports as @imports" do
      import = @business.imports.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      assigns(:imports).should eq([import])
    end
  end

  describe "GET show" do
    it "should be successful" do
      import = @business.imports.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => import.to_param
      response.should be_success
    end

    it "assigns the requested business as @business" do
      import = @business.imports.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => import.to_param}
      assigns(:import).should == import
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      assigns(:import).should be_a_new(Import)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      import = @business.imports.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => @business.to_param}
      assigns(:import).should eq(import)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Import" do
        expect {
          post :create, {:business_id => @business.to_param, :import => valid_attributes}
        }.to change(Import, :count).by(1)
      end

      it "assigns a newly created import as @imports" do
        post :create, {:business_id => @business.to_param, :import => valid_attributes}
        assigns(:import).should be_a(Import)
        assigns(:import).should be_persisted
      end

      it "redirects to the created import" do
        post :create, {:business_id => @business.to_param, :import => valid_attributes}
        response.should redirect_to(business_import_url(@business,Import.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved import as @import" do
        # Trigger the behavior that occurs when invalid params are submitted
        Import.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :import => {}}
        assigns(:import).should be_a_new(Import)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Import.any_instance.stub(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :import => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested import" do
        import = @business.imports.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Import.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:business_id => @business.to_param, :id => import.to_param, :import => {'these' => 'params'}}
      end

      it "assigns the requested import as @import" do
        import = @business.imports.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => import.to_param, :import => valid_attributes}
        assigns(:import).should eq(import)
      end

      it "redirects to the import" do
        import = @business.imports.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => import.to_param, :import => valid_attributes}
        response.should redirect_to(business_import_url(@business, import))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        import = @business.imports.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Import.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => import.to_param, :import => {}}
        assigns(:import).should eq(import)
      end

      it "re-renders the 'edit' template" do
        import = @business.imports.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Import.any_instance.stub(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => import.to_param, :import => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      import = @business.imports.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => import.to_param}
      }.to change(Import, :count).by(-1)
    end

    it "redirects to the businesses list" do
      import = @business.imports.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => import.to_param}
      response.should redirect_to(business_imports_url(@business))
    end
  end

end
