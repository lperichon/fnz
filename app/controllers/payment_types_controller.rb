class PaymentTypesController < UserApplicationController
  before_filter :get_business

  def index
    @payment_types = @business.payment_types.order("name")
  end

  def show
    @payment_type = @business.payment_types.find(params[:id])
  end

  def edit
    @payment_type = @business.payment_types.find(params[:id])
  end
  
  def new
    @payment_type = @business.payment_types.new(payment_type_params)
  end

  # POST /payment_types
  # POST /payment_types.json
  def create
    @payment_type = @business.payment_types.new(payment_type_params)

    respond_to do |format|
      if @payment_type.save
        format.html { redirect_to business_payment_types_path(@business), notice: 'Payment type was successfully created.' }
        format.json { render json: @payment_type, status: :created, location: business_payment_type_path(@business,@payment_type) }
      else
        format.html { render action: "new" }
        format.json { render json: @payment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payment_types/1
  # PUT /payment_types/1.json
  def update
    @payment_type = @business.payment_types.find(params[:id])

    respond_to do |format|
      if @payment_type.update_attributes(payment_type_params || {})
        format.html { redirect_to business_payment_types_path(@business), notice: 'Payment type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_types/1
  # DELETE /payment_types/1.json
  def destroy
    @payment_type = @business.payment_types.find(params[:id])
    @payment_type.destroy

    respond_to do |format|
      format.html { redirect_to business_payment_types_url(@business) }
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

  def payment_type_params
    params.require(:payment_type).permit(
      :name,
      :description
    ) if params[:payment_type].present?
  end
end
