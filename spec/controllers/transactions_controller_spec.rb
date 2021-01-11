require 'rails_helper'

describe TransactionsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :description => "Test Transaction",
      :amount => 3.5,
      :source_id => @account.id,
      :business_id => @business.id,
      :transaction_at => Date.today,
      :creator_id => @business.owner.id,
      :type => "Debit"
    }
  end

  before(:each) do
    class Debit < Transaction
    end
    @account =  FactoryBot.create(:account)
    @business = @account.business
    @user = @account.business.owner
    sign_in @user
  end

  describe "GET business transactions index" do
    it "assigns all transactions as @transactions" do
      transaction = @business.trans.create! valid_attributes
      transaction = Transaction.last
      get :index, {:business_id => @business.to_param}
      expect(assigns(:transactions)).to eq([transaction])
    end
  end

  describe "GET show" do
    it "should be successful" do
      transaction = @business.trans.create! valid_attributes
      get :show, :business_id => @business.to_param, :id => transaction.to_param
      expect(response).to be_success
    end

    it "assigns the requested transaction as @transaction" do
      @business.trans.create! valid_attributes
      transaction = Transaction.last
      get :show, :business_id => @business.to_param, :id => transaction.to_param
      expect(assigns(:transaction)).to eq transaction
    end
  end

  describe "GET new" do
    it "assigns a new transaction as @transaction" do
      get :new, :business_id => @business.to_param
          expect(assigns(:transaction)).to be_a_new(Transaction)
    end
  end

  describe "GET edit" do
    it "assigns the requested transaction as @transaction" do
      @business.trans.create! valid_attributes
      transaction = Transaction.last
      get :edit, :business_id => @business.to_param, :id => transaction.to_param
      expect(assigns(:transaction)).to eq(transaction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Transaction" do
        expect {
          post :create, {:business_id => @business.to_param, :transaction => valid_attributes}
        }.to change(Transaction, :count).by(1)
      end

      it "assigns a newly created transaction as @transaction" do
        post :create, {:business_id => @business.to_param, :transaction => valid_attributes}
        expect(assigns(:transaction)).to be_a(Transaction)
        expect(assigns(:transaction)).to be_persisted
      end

      it "assigns the current user to the created transaction as creator" do
        post :create, {:business_id => @business.to_param, :transaction => valid_attributes}
        expect(assigns(:transaction).creator).to eq(@account.business.owner)
      end

      it "redirects to the created transaction" do
        post :create, {:business_id => @business.to_param, :transaction => valid_attributes}
        expect(response).to redirect_to(business_transaction_url(@business, Transaction.last))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved transaction as @transaction" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Transaction).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :transaction => {}}
        expect(assigns(:transaction)).to be_a_new(Transaction)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Transaction).to receive(:save).and_return(false)
        post :create, {:business_id => @business.to_param, :transaction => {}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested transaction" do
        transaction = @business.trans.create! valid_attributes
        # Assuming there are no other businesses in the database, this
        # specifies that the Business created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Transaction).to receive(:update_attributes).with({'description' => 'params'})
        put :update, {:business_id => @business.to_param, :id => transaction.to_param, :transaction => {'description' => 'params'}}
      end

      it "assigns the requested transaction as @transaction" do
        @business.trans.create! valid_attributes
        transaction = Transaction.last
        put :update, {:business_id => @business.to_param, :id => transaction.to_param, :transaction => valid_attributes}
        expect(assigns(:transaction)).to eq(transaction)
      end

      it "redirects to the transaction" do
        transaction = @business.trans.create! valid_attributes
        put :update, {:business_id => @business.to_param, :id => transaction.to_param, :transaction => valid_attributes}
        expect(response).to redirect_to(business_transaction_url(@business, transaction))
      end
    end

    describe "with invalid params" do
      it "assigns the transaction as @transaction" do
        @business.trans.create! valid_attributes
        transaction = Transaction.last
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Transaction).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => transaction.to_param, :transaction => {}}
        expect(assigns(:transaction)).to eq(transaction)
      end

      it "re-renders the 'edit' template" do
        transaction = @business.trans.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Transaction).to receive(:save).and_return(false)
        put :update, {:business_id => @business.to_param, :id => transaction.to_param, :transaction => {}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before do
      request.env["HTTP_REFERER"] = "/businesses/#{@business.id}/transactions"
    end

    it "destroys the requested transaction" do
      transaction = @business.trans.create! valid_attributes
      expect {
        delete :destroy, {:business_id => @business.to_param, :id => transaction.to_param}
      }.to change(Transaction, :count).by(-1)
    end

    it "redirects to the businesses list" do
      transaction = @business.trans.create! valid_attributes
      delete :destroy, {:business_id => @business.to_param, :id => transaction.to_param}
      expect(response).to redirect_to(business_transactions_url(@business))
    end
  end

end
