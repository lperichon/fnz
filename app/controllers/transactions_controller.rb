class TransactionsController < UserApplicationController
  include ReceiptsHelper

  before_filter :get_context

  PER_PAGE = 200
  def index
    @context = @context.order("order_stamp DESC")

    @transactions = @context.includes(:agent, :contact, :tags, :source, :business)

    if @account && @start_date
      @starting_balance = @account.calculate_balance_cents(@start_date) / 100.0
    end

    if @account && @end_date && @end_date < Time.zone.today
      eb = @account.calculate_balance_cents(@end_date) / 100.0
      if eb != @account.balance
        @ending_balance = eb
      end
    end

    if @tag && @report_date
      @dates = []
      @tree_totals = { }

      last_date = if @report_date < Date.today.beginning_of_month
        Date.today.beginning_of_month
      else
        @report_date
      end

      rd = last_date
      while rd > @report_date-3.months
        @dates << rd
        [@tag,@tag.children].flatten.each do |tag|
          @tree_totals[tag] = {} if @tree_totals[tag].nil?
          @tree_totals[tag][rd] = tag.month_total(rd)
        end
        rd = rd-1.month
      end
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
    @transaction = @context.new(transaction_attributes_for_new)
    if params[:quick]
      render layout: "quick_mobile"
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @transaction = @context.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        return_to_url = if params[:quick]
          if @transaction.receipt_on_create
            receipt_business_transaction_path(@business, @transaction)
          else
            new_business_transaction_path(@business, quick: 1)
          end
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
    authorize! :update, @transaction

    respond_to do |format|
      if @transaction.update_attributes(transaction_attributes_for_update || {})
        format.html { redirect_to business_transaction_path(@business, @transaction), notice: _("Movimiento actualizado") }
        format.js {}
        format.json do
          respond_with_bip(@transaction.becomes(Transaction), param: transaction_param_key)
        end
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { respond_with_bip(@transaction.becomes(Transaction), param: transaction_param_key) }
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
    @transactions.each { |t| authorize! :update, t }
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
    authorize! :destroy, @transaction

    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def receipt
    @transaction = @business.trans.find(params[:id])
    if (@receipt = @transaction.receipt).nil?
      @receipt = @transaction.generate_receipt
    end

    redirect_to public_receipt_url(receipt)
  end

  private

  def transaction_param_key
    if params[:credit]
      :credit
    elsif params[:debit]
      :debit
    else
      :transaction
    end
  end

  def transaction_attributes_for_new
    attrs = ( transaction_params || {}).reverse_merge({
      type: 'Debit',
      transaction_at: Time.zone.now
    })
    if @business
      attrs = attrs.reverse_merge({
        source_id: @business.accounts.where(default: true).first.try(:id)
      })
    end
    attrs.is_a?(ActionController::Parameters) ? attrs.permit! : attrs
  end

  def transaction_attributes_for_update
    transaction_params
  end

  def transaction_attributes_for_batch_update
    # TODO remove blanks
    params.require(:transaction).reject{|k,v| v.blank? }.permit!
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
      @context = @business.trans
      if source_id
        @account = @business.accounts.find(source_id)
        if params[:active_only]
          @context = @account.active_transactions
        else
          @context = @account.trans
        end
      end
    end

    if params[:transaction_search]
      @transaction_search = TransactionSearch.new({base_scope: @context, business_id: @business.id}.merge(params[:transaction_search]))
      if @transaction_search.period_filter?
        @meta_period = @transaction_search.smart_meta_period
      end
      @context = @transaction_search.results
    else
      @transaction_search = TransactionSearch.new(base_scope: @context)
      @meta_period = params[:meta_period] || "current_month"
      @start_date = Date.parse(params[:start_date] || Time.zone.today.beginning_of_month.to_s).beginning_of_day
      if params[:end_date] == "Invalid date"
        params[:end_date] = nil
      end
      @end_date = Date.parse(params[:end_date] || Time.zone.today.end_of_month.to_s).end_of_day

      if params[:report_on]
        @report_date = Date.parse( params[:report_on] )
        @context = @context.to_report_on_month(@report_date)
      else
        # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
        @context = @context.where("(transaction_at >= :start AND transaction_at <= :end) OR (state = 'pending' AND transaction_at <= :start) OR (state = 'reconciled' AND reconciled_at >= :start AND reconciled_at <= :end)", {start: @start_date.to_time, end: @end_date.to_time})
      end
    end

    if params[:admpart_tag_id]
      @tag = Tag.find params[:admpart_tag_id]
      @context = @context.where(admpart_tag_id: @tag.self_and_descendants.map(&:id))
    end

    @context = @context.api_where(filter_params)
  end

  def filter_params
    if params[:q]
      params.require(:q).permit!
    end
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

  def transaction_params
    params.require(transaction_param_key).permit(
      :tag_id,
      :description,
      :business_id,
      :source_id,
      :amount,
      :type,
      :transaction_at,
      :target_id,
      :conversion_rate,
      :state,
      :reconciled_at,
      :sale_ids,
      :installment_ids,
      :enrollment_ids,
      :creator_id,
      :report_at,
      :report_at_option,
      :inscription_ids,
      :contact_id,
      :agent_id,
      :admpart_tag_id,
      :tag_ids,
      :receipt_on_create,
      tag_ids: []
    ) if params[transaction_param_key].present?
  end
end
