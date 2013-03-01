class TransactionsController < UserApplicationController

  before_filter :get_context

  def index
    @context = @context.order("transaction_at DESC")
    # List transactions on this month or the year/month solicited
    start_date = Date.new(params[:year].present? ? params[:year].to_i : Date.today.year, params[:month].present? ? params[:month].to_i : (params[:year].present? ? 1 : Date.today.month), 1).beginning_of_month.beginning_of_day
    end_date = Date.new(params[:year].present? ? params[:year].to_i : Date.today.year, params[:month].present? ? params[:month].to_i : (params[:year].present? ? 12 : Date.today.month), 28).end_of_month.end_of_day

    # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
    @context = @context.where {(transaction_at.gteq start_date) & (transaction_at.lteq end_date) |
                              ((state.eq 'pending') & (transaction_at.lt start_date)) |
                              ((state.eq 'reconciled') & (reconciled_at.gteq start_date) & (reconciled_at.lteq end_date))}
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

  def stats
    @context = @context
    # List transactions on this month or the year/month solicited
    start_date = Date.new(params[:year].present? ? params[:year].to_i : Date.today.year, params[:month].present? ? params[:month].to_i : (params[:year].present? ? 1 : Date.today.month), 1).beginning_of_month.beginning_of_day
    end_date = Date.new(params[:year].present? ? params[:year].to_i : Date.today.year, params[:month].present? ? params[:month].to_i : (params[:year].present? ? 12 : Date.today.month), 28).end_of_month.end_of_day

    # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
    @context = @context.where {(transaction_at.gteq start_date) & (transaction_at.lteq end_date) |
        ((state.eq 'pending') & (transaction_at.lt start_date)) |
        ((state.eq 'reconciled') & (reconciled_at.gteq start_date) & (reconciled_at.lteq end_date))}

    @debits = @context.where(:type => "Debit").joins(:tags).group('tags.name').sum(:amount)
    @untagged_debits = @context.where(:type => "Debit").untagged.sum(:amount)
    @credits = @context.where(:type => "Credit").joins(:tags).group('tags.name').sum(:amount)
    @untagged_credits = @context.where(:type => "Credit").untagged.sum(:amount)
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
