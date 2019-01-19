class AdmpartsController < UserApplicationController
  include RedirectBackHelper
  
  layout "application_without_sidebar"

  before_filter :store_location, only: [:index, :show, :overview, :destroy]

  before_filter :get_context

  def show
    @ref_date = if params[:ref_date]
      Date.parse(params[:ref_date])
    else
      Time.zone.today
    end

    @adm = Admpart.find_or_create_by_business_id(@business.id)
  end

  def edit

  end

  private

  def get_context
    business_id = params[:business_id]
    business_id = params[:membership][:business_id] unless business_id || params[:membership].blank?
    param_is_padma_id = (false if Float(business_id) rescue true)
    
    if current_user.admin?
      @business_context = Business
    else
      @business_context = current_user.businesses
    end

    if business_id
      if param_is_padma_id
        @business = @business_context.find_by_padma_id(params[:business_id])
      else
        @business = @business_context.find(params[:business_id])
      end
      @context = @business.memberships
    end
  end
end
