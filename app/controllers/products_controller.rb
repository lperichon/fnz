class ProductsController < UserApplicationController
  before_filter :get_business

  def index
    @products = @business.products.order('hidden ASC')
  end

  def show
    @product = @business.products.find(params[:id])
  end

  def edit
    @product = @business.products.find(params[:id])
  end

  def new
    @product = @business.products.new(product_params)
  end

  # POST /products
  # POST /products.json
  def create
    @product = @business.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to business_product_path(@business, @product), notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: business_product_path(@business, @product) }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = @business.products.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(product_params || {})
        format.html { redirect_to business_product_path(@business, @product), notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = @business.products.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to business_products_url(@business) }
      format.json { head :no_content }
    end
  end

  private

  def get_business
    @business = get_context.find(params[:business_id])
  end
  
  def get_context
    @context = nil
    if current_user.admin?
      @context = Business
    else
      @context = current_user.businesses
    end
    @context
  end

  def product_params
    params.require(:product).permit(
      :name,
      :business_id,
      :price,
      :price_currency,
      :cost,
      :cost_currency,
      :stock,
      :hidden,
      :external_id
    ) if params[:product].present?
  end
end
