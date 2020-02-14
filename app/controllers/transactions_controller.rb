class TransactionsController < UserApplicationController

  before_filter :get_context

  PER_PAGE = 200
  def index
    @context = @context.order("transaction_at DESC")

    @transactions = @context.includes(:agent, :contact, :tags, :source, :business)

    if @account && @start_date
      @starting_balance = @account.calculate_balance(@start_date)
    end

    if @account && @end_date && @end_date < Time.zone.today
      eb = @account.calculate_balance(@end_date)
      if eb != @account.balance
        @ending_balance = eb
      end
    end

    if @tag && @report_date
      @tree_totals = {}
      @tag.self_and_descendants.each{|tag| @tree_totals[tag] = tag.month_total(@report_date) }
    end

    respond_to do |format|
      format.html do
        get_download_api_key
        @transactions = @transactions.page(params[:page]).per(params[:per_page] || PER_PAGE )
      end
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"transactions.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def new
    attrs = ( params[:transaction] || {}).reverse_merge({
      type: 'Debit',
      transaction_at: Time.zone.now
    })
    if @business
      attrs = attrs.reverse_merge({
        source_id: @business.accounts.where(default: true).first.try(:id)
      })
    end
    @transaction = @context.new(attrs)
    if params[:quick]
      render layout: "quick_mobile"
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @transaction = @context.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        return_to_url = if params[:quick]
          new_business_transaction_path(@business, quick: 1)
        else
          business_transaction_path(@business, @transaction)
        end
        format.html { redirect_to return_to_url, notice: _('Movimiento creado') }
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
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(transaction_attributes_for_update)
        format.html { redirect_to business_transaction_path(@business, @transaction), notice: _("Movimiento actualizado") }
        format.js {}
        format.json { respond_with_bip(@transaction.becomes(Transaction)) }
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { respond_with_bip(@transaction.becomes(Transaction)) }
      end
    end
  end

  def batch_edit
    @transaction = Transaction.new
    @transaction.state = ""
    respond_to do |format|
      format.js
    end
  end
  def batch_update
    @transactions = Transaction.where(id: params[:ids])
    @success = true
    @transactions.find_each{|t| @success &&= t.update_attributes(transaction_attributes_for_batch_update) } # trigger callbacks
    respond_to do |format|
      format.js 
    end
  end


  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def stats
    @context = @context
    # List transactions on this month or the year/month solicited
    start_date = @start_date = Date.parse(params[:start_date] || Date.today.beginning_of_month.to_s).beginning_of_day
    end_date = @end_date = Date.parse(params[:end_date] || Date.today.end_of_month.to_s).end_of_day

    # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
    @context = @context.where {(transaction_at.gteq start_date) & (transaction_at.lteq end_date)}

    @debits = @context.where(:type => "Debit").joins(:tags).includes(:source).group("concat(tags.name, '-', accounts.currency)").sum(:amount)
    @untagged_debits = @context.where(:type => "Debit").untagged.sum(:amount)
    @credits = @context.where(:type => "Credit").joins(:tags).includes(:source).group("concat(tags.name, '-', accounts.currency)").sum(:amount)
    @untagged_credits = @context.where(:type => "Credit").untagged.sum(:amount)
  end

  private

  def transaction_attributes_for_update
    if params[:credit]
      params[:transaction] = params.delete(:credit)
    end
    if params[:debit]
      params[:transaction] = params.delete(:debit)
    end
    params[:transaction]
  end

  def transaction_attributes_for_batch_update
    # TODO remove blanks
    params[:transaction].reject{|k,v| v.blank? }
  end

  def get_context
    business_id = params[:business_id]
    source_id = params[:account_id]

    if current_user.admin?
      @business_context = Business
    else
      @business_context = current_user.businesses
    end

    @context = Transaction
    if business_id
      @business = @business_context.find(business_id)
      @context = @business.transactions
      if source_id
        @account = @business.accounts.find(source_id)
        if params[:active_only]
          @context = @account.active_transactions
        else
          @context = @account.transactions
        end
      end
    end

    if params[:admpart_tag_id]
      @tag = Tag.find params[:admpart_tag_id]
      @context = @business.transactions.where(admpart_tag_id: @tag.self_and_descendants.map(&:id))
    end

    # List transactions on this month or the year/month solicited
    start_date = @start_date = Date.parse(params[:start_date] || Time.zone.today.beginning_of_month.to_s).beginning_of_day
    end_date = @end_date = Date.parse(params[:end_date] || Time.zone.today.end_of_month.to_s).end_of_day

    if params[:report_on]
      @report_date = Date.parse( params[:report_on] )
      @context = @context.to_report_on_month(@report_date)
    else
      # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
      @context = @context.where {(transaction_at.gteq start_date.to_time) & (transaction_at.lteq end_date.to_time) |
                                ((state.eq 'pending') & (transaction_at.lt start_date)) |
                                ((state.eq 'reconciled') & (reconciled_at.gteq start_date.to_time) & (reconciled_at.lteq end_date.to_time))}
    end

    @context = @context.api_where(params[:q])
  end

  def get_download_api_key
    return if @business.nil?

    if @download_api_key
      @download_api_key
    else
      possible_keys = ApiKey.paginate(where: {
        account_name: @business.padma_id,
        access: [:public_downloads, :login_key]
      })
      if possible_keys
        mine = possible_keys.select{|ak| ak.username == current_user.username }.first
        @download_api_key = if mine
          mine.try(:key)
        else
          possible_keys.last.try(:key)
        end
      end
    end
  end

end
