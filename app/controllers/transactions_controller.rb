class TransactionsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :get_context

  def index
    @transactions = @context.all
  end

  def show
    @transaction = @context.find(params[:id])
    @business = @transaction.business
  end

  def edit
    @transaction = @context.find(params[:id])
    @business = @transaction.business
  end

  def new
    @transaction = @context.new(params[:transaction])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @transaction = @context.new(params[:transaction])
    @transaction.creator = current_user
    @business = @transaction.business

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to transaction_path(@transaction), notice: 'Transaction was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @transaction = @context.find(params[:id])
    @business = @transaction.business

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to transaction_path(@transaction), notice: 'Transaction was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @transaction = @context.find(params[:id])
    @business = @transaction.business unless @business
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to business_transactions_url(@business) }
    end
  end

  private

  def get_context
    business_id = params[:business_id]
    business_id = params[:transaction][:business_id] unless business_id || params[:transaction].blank?
    source_id = params[:account_id]
    source_id = params[:transaction][:source_id] unless source_id || params[:transaction].blank?
    @context = Transaction
    if business_id
      @business = current_user.businesses.find(business_id)
      @context = @business.transactions
      if source_id
        @account = @business.accounts.find(source_id)
        @context = @account.transactions
      end
    end
  end

end
