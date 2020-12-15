class SalesController < UserApplicationController

  before_filter :get_context

  def index
    # List transactions on this month or the year/month solicited
    start_date = @start_date = Date.parse(params[:start_date] || Date.today.beginning_of_month.to_s).beginning_of_day
    end_date = @end_date = Date.parse(params[:end_date] || Date.today.end_of_month.to_s).end_of_day

    @sales = @context.where {(sold_on.gteq start_date) & (sold_on.lteq end_date)}
  end

  def show
    @sale = @context.find(params[:id])
    @business = @sale.business
  end

  def edit
    @sale = @context.find(params[:id])
    @business = @sale.business
    date = @sale.sold_on
    @transactions = @business.trans.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("order_stamp DESC")
  end

  def new
    @sale = @context.new(sale_params)
    date = Date.today
    @transactions = @business.trans.credits.where {(transaction_at.gteq(date - 1.month)) & (transaction_at.lteq(date + 1.month))}.order("order_stamp DESC")
  end

  # POST /accounts
  # POST /accounts.json
  def create
    padma_contact_id = params[:sale].delete(:padma_contact_id)
    @sale = @context.new(sale_params)
    @business = @sale.business

    # Setting padma_contact_id is performed last as it depends on business_id being already set
    @sale.padma_contact_id = padma_contact_id if padma_contact_id.present?

    respond_to do |format|
      if @sale.save
        format.html { redirect_to business_sale_path(@business, @sale), notice: 'Sale was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @sale = @context.find(params[:id])
    @business = @sale.business

    respond_to do |format|
      if @sale.update_attributes(sale_params || {})
        format.html { redirect_to business_sale_path(@business, @sale), notice: 'Sale was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @sale = @context.find(params[:id])
    @business = @sale.business unless @business
    @sale.destroy

    respond_to do |format|
      format.html { redirect_to business_sales_url(@business) }
    end
  end

  def stats
    @stats = SaleStats.new(:business => @business, :year => params[:year].to_i, :month => params[:month].to_i)
  end

  private

  def get_context
    business_id = params[:business_id]

    if current_user.admin?
      @business_context = Business
    else
      @business_context = current_user.businesses
    end

    @context = Sale
    if business_id
      @business = @business_context.find(business_id)
      @context = @business.sales
    end
  end

  def sale_params
    params.require(:sale).permit(
      :contact_id,
      :business_id,
      :agent_id,
      :product_id,
      :sold_on,
      :external_id,
      :transactions_attributes,
      :sale_transactions_attributes
    ) if params[:sale].present?
  end
end
