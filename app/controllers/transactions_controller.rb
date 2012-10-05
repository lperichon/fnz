class TransactionsController < UserApplicationController

  before_filter :get_context

  def index
    @transactions = @context.all
  end

  def show
    @transaction = @context.find(params[:id])
  end

  def edit
    @transaction = @context.find(params[:id])
  end

  def new
    @transaction = @context.new(params[:transaction])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @transaction = @context.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to business_transaction_path(@business, @transaction), notice: 'Transaction was successfully created.' }
        format.json { render json: @transaction, status: :created, location: business_transaction_path(@business, @transaction) }
        format.js {}
      else
        format.html { render action: "new" }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
        format.js {}
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @transaction = @context.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to business_transaction_path(@business, @transaction), notice: 'Transaction was successfully updated.' }
        format.js {}
      else
        format.html { render action: "edit" }
        format.js {}
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @transaction = @context.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to business_transactions_url(@business) }
    end
  end

  private

  def get_context
    business_id = params[:business_id]
    source_id = params[:account_id]
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
