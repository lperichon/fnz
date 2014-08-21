require 'spec_helper'

describe PaymentsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Business. As you add validations to Business, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      :source_id => @account.id,
      :transaction_at => Date.today
    }
  end

  before(:each) do
  	class Credit < Transaction
    end
    @business = FactoryGirl.create(:school)
    @account =  FactoryGirl.create(:account, :business => @business)
    @membership = FactoryGirl.create(:membership, :business => @business)
    @installment = FactoryGirl.create(:installment, :membership => @membership)
    @user = @business.owner
    sign_in @user
  end

  describe "GET new" do
    it "assigns a new transaction as @transaction" do
      xhr :get, :new, :business_id => @business.to_param, 
      	:membership_id => @membership.to_param, 
      	:installment_id => @installment.to_param
      assigns(:transaction).should be_a_new(Transaction)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Transaction" do
        expect {
          xhr :post, :create, {
          	:business_id => @business.to_param, 
          	:membership_id => @membership.to_param,
          	:installment_id => @installment.to_param,
           	:transaction => valid_attributes
          }
        }.to change(Transaction, :count).by(1)
      end

      it "assigns a newly created transaction as @transaction" do
        xhr :post, :create, {
          	:business_id => @business.to_param, 
          	:membership_id => @membership.to_param,
          	:installment_id => @installment.to_param,
           	:transaction => valid_attributes
        }
        assigns(:transaction).should be_a(Transaction)
        assigns(:transaction).should be_persisted
      end

      it "assigns the current user to the created transaction as creator" do
        xhr :post, :create, {
          	:business_id => @business.to_param, 
          	:membership_id => @membership.to_param,
          	:installment_id => @installment.to_param,
           	:transaction => valid_attributes
          }
        assigns(:transaction).creator.should eq(@account.business.owner)
      end

      it "links the new transaction with the installment" do
        xhr :post, :create, {
          	:business_id => @business.to_param, 
          	:membership_id => @membership.to_param,
          	:installment_id => @installment.to_param,
           	:transaction => valid_attributes
          }
        assigns(:transaction).installments.first.should eq(@installment)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved transaction as @transaction" do
        # Trigger the behavior that occurs when invalid params are submitted
        Transaction.any_instance.stub(:save).and_return(false)
        xhr :post, :create, {
          	:business_id => @business.to_param, 
          	:membership_id => @membership.to_param,
          	:installment_id => @installment.to_param,
           	:transaction => {}
          }
        assigns(:transaction).should be_a_new(Transaction)
      end
    end
  end
end
