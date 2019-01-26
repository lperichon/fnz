class AdmpartsController < UserApplicationController
  include RedirectBackHelper
  
  layout "application_without_sidebar"

  before_filter :store_location, only: [:index, :show, :overview, :destroy]

  before_filter :get_context

  before_filter :get_admpart, only: [:show, :edit, :attendance_detail]
  def show
    @ref_date = if params[:ref_date]
      Date.parse(params[:ref_date])
    else
      Time.zone.today
    end

    if @adm

      unless params[:skip_refresh]
        @adm.queue_refresh_cache
        Appsignal.instrument("waiting") do
          sleep(2) # wait 2 seconds, usually enough for webservices to be cached
        end
        params.delete(:action)
        redirect_to business_admpart_path(params.merge({id: @adm.id, skip_refresh: true}))
      end

    else
      redirect_to edit_business_admpart_path(@business, id: :current)
    end
  end

  def attendance_detail
    @adm.force_refresh = params[:force_refresh] 

    @ignore_zero_income = !params[:show_zero_income]

    @contacts = @adm.contacts_in_attendance_report
  end

  def edit
    if @adm.nil?
      @adm = @business.current_admpart
    end
    @adm.force_refresh = true
  end

  def update
    @adm = Admpart.find_or_create_by_business_id(@business.id)
    if @adm.update_attributes(params[:admpart])
      redirect_to business_admpart_path(@business, @adm)
    else
      render :edit
    end
  end

  private

  # get admpart from id (current or id) or from ref_date
  def get_admpart
    id = params[:id] || params[:admpart_id]
    @adm = if id
       if id.to_s == "current"
         @business.current_admpart
       else
         Admpart.find(id)
       end
    elsif params[:ref_date]
      Admpart.where(business_id: @business.id).for_ref_date(params[:ref_date]).first
    end
  end

  def get_context
    business_id = params[:business_id]
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
    end
  end
end
