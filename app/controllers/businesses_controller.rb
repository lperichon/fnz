class BusinessesController < UserApplicationController
  def index
    @businesses = current_user.user_businesses
  end

  def show
    @business = current_user.businesses.find(params[:id])
  end

  def edit
    @business = current_user.owned_businesses.find(params[:id])
  end

  def new
    @business = current_user.owned_businesses.new(business_params)
  end

  # POST /businesses
  # POST /businesses.json
  def create
      @business = current_user.owned_businesses.new(business_params)

    respond_to do |format|
      if @business.save
        format.html { redirect_to business_path(@business), notice: 'Business was successfully created.' }
        format.json { render json: @business, status: :created, location: @business }
      else
        format.html { render action: "new" }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /businesses/1
  # PUT /businesses/1.json
  def update
    @business = Business.find(params[:id])
    authorize! :update, @business

    respond_to do |format|
      if @business.update_attributes(business_params || {})
        format.html { redirect_to business_path(@business), notice: 'Business was successfully updated.' }
        format.json do
          respond_with_bip(@business.becomes(Business), param: param_key)
        end
      else
        format.html { render action: "edit" }
        format.json do
          respond_with_bip(@business.becomes(Business), param: param_key)
        end
      end
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business = current_user.owned_businesses.find(params[:id])
    @business.destroy

    respond_to do |format|
      format.html { redirect_to businesses_url }
      format.json { head :no_content }
    end
  end

  private

  def business_params
    params.require(:business).permit(
      :type,
      :name,
      :owner_id,
      :padma_id,
      :synchronzied_at,
      :send_weekly_reports,
      :transactions_enabled,
      :share_enabled,
      :use_calendar_installments,
      :currency_code,
      :block_transactions_before
    ) if params[:business].present?
  end

  def param_key
    if params[:school]
      :school
    else
      :business
    end
  end
end
