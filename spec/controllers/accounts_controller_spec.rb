require 'rails_helper'

describe AccountsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :name => "Test Account"
    }
  end

  before(:each) do
    @business = FactoryBot.create(:business)
    sign_in @business.owner
  end

  describe "GET index" do
    it "assigns all accounts as @accounts" do
      account = @business.accounts.create! valid_attributes
      get :index, {:business_id => @business.to_param}
      expect(assigns(:accounts)).to eq([account])
    end
  end

  describe "GET show" do
    it "should be successful" do
      account = @business.accounts.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => account.to_param
      expect(response).to be_success
    end

    it "assigns the requested business as @business" do
      account = @business.accounts.create! valid_attributes
      get :show, {:business_id => @business.to_param, :id => account.to_param}
      expect(assigns(:account)).to eq account
    end
  end

  describe "GET new" do
    it "assigns a new business as @business" do
      get :new, {:business_id => @business.to_param}
      expect(assigns(:account)).to be_a_new(Account)
    end
  end

  describe "GET edit" do
    it "assigns the requested business as @business" do
      account = @business.accounts.create! valid_attributes
      get :edit, {:business_id => @business.to_param, :id => account.to_param}
      expect(assigns(:account)).to eq(account)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Account" do
        expect {
          post :create, {:business_id => @business.to_param, :account => valid_attributes}
        }.to change(Account, :count).by(1)
      end

      it "assigns a newly created account as @accounts" do
        post :create, {:business_id => @business.to_param, :account => valid_attributes}
        expect(assigns(:account)).to be_a(Account)
        expect(assigns(:account)).to be_persisted
      end

      it "redirects to the created account" do
        post :create, {:business_id => @business.to_param, :account => valid_attributes}
        expect(response).to redirect_to(business_account_url(@business,Account.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved account as @account" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Account).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :account => {}}
        expect(assigns(:account)).to be_a_new(Account)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Account).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :account => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested account" do
        account = @business.accounts.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Account).to receive(:update_attributes).with({'name' => 'params'})
        put :update, {:business_id => @business.to_param, :id => account.to_param, :account => {'name' => 'params'}}
      end

      it "assigns the requested account as @account" do
        account = @business.accounts.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => account.to_param, :account => valid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it "redirects to the account" do
        account = @business.accounts.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => account.to_param, :account => valid_attributes}
        expect(response).to redirect_to(business_account_url(@business, account))
      end
    end

    describe "with invalid params" do
      it "assigns the business as @business" do
        account = @business.accounts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Account).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => account.to_param, :account => {}}
        expect(assigns(:account)).to eq(account)
      end

      it "re-renders the 'edit' template" do
        account = @business.accounts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Account).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => account.to_param, :account => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested business" do
      account = @business.accounts.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => account.to_param}
      }.to change(Account, :count).by(-1)
    end

    it "redirects to the businesses list" do
      account = @business.accounts.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => account.to_param}
      expect(response).to redirect_to(business_accounts_url(@business))
    end
  end

end
