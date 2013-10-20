class SalesController < UserApplicationController

  before_filter :get_context

  def index
    @sales = @context.all
  end

  def show
    @sale = @context.find(params[:id])
    @business = @sale.business
  end

  def edit
    @sale = @context.find(params[:id])
    @business = @sale.business
  end

  def new
    @sale = @context.new(params[:sale])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    padma_contact_id = params[:sale].delete(:padma_contact_id)
    @sale = @context.new(params[:sale])
    @business = @sale.business

    # Setting padma_contact_id is performed last as it depends on business_id being already set
    @sale.padma_contact_id = padma_contact_id

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
      if @sale.update_attributes(params[:sale])
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
    @context = Sale
    if business_id
      @business = current_user.businesses.find(business_id)
      @context = @business.sales
    end
  end

end
