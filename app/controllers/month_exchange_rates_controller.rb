class MonthExchangeRatesController < UserApplicationController
  before_filter :get_business

  def index
    @month_exchange_rates = @business.month_exchange_rates.order("ref_date DESC, from_currency_id ASC")
  end

  def get_rate
    render json: {
      rate: @business.month_exchange_rates.conversion_rate(params[:from], params[:to], params[:ref_date])
    }, code: 200
  end

  def refresh_rate
    @month_exchange_rate = @business.month_exchange_rates.find(params[:id])
    @month_exchange_rate.update_rate_from_3rd_party
    redirect_to business_month_exchange_rates_path(@business)
  end

  def new
    @month_exchange_rate = @business.month_exchange_rates.new
  end

  def create
    @month_exchange_rate = @business.month_exchange_rates.new(month_exchange_rate_params)

    respond_to do |format|
      if @month_exchange_rate.save
        format.html { redirect_to business_month_exchange_rates_path(@business), notice: "ok" }
        format.json { render json: @month_exchange_rate, status: :created, location: @month_exchange_rate }
      else
        format.html do
          render action: "new"
        end
        format.json { render json: @month_exchange_rate.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @month_exchange_rate = @business.month_exchange_rates.find(params[:id])

    respond_to do |format|
      if @month_exchange_rate.update_attributes(month_exchange_rate_params || {})
        format.html { redirect_to business_month_exchange_rates_path(@business), notice: "ok" }
        format.js {}
        format.json do
          respond_with_bip(@month_exchange_rate, param: param_key)
        end
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { respond_with_bip(@month_exchange_rate, param: param_key) }
      end
    end
  end

  def destroy
    @month_exchange_rate = @business.month_exchange_rates.find(params[:id])
    @month_exchange_rate.destroy
    redirect_to business_month_exchange_rates_path(business_id: @business.id)
  end

  private

  def param_key
    :month_exchange_rate
  end

  def get_business
    @business = Business.find(params[:business_id])
  end

  def month_exchange_rate_params
    if params[:month_exchange_rate]
      params.require(:month_exchange_rate).permit!
    end
  end
end
