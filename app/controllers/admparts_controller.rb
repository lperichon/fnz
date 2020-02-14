class AdmpartsController < UserApplicationController
  include RedirectBackHelper
  
  layout "application_without_sidebar"

  before_filter :store_location, except: [:edit]

  before_filter :get_context
  before_filter :get_admpart, only: [:show, :edit, :update, :attendance_detail]

  def show
    if @adm.valid?
      unless params[:skip_refresh]
        @adm.queue_refresh_cache
        Appsignal.instrument("waiting") do
          sleep(2) # wait 2 seconds, usually enough for webservices to be cached
        end
        params.delete(:action)
        if params[:year]
          redirect_to dated_admpart_business_admparts_path(params.merge(skip_refresh: true))
        else
          redirect_to business_admpart_path(params.merge({skip_refresh: true}))
        end
      end

    else
      redirect_to edit_business_admpart_path(@business, id: @adm.try(:ref_date) || Date.today)
    end
  end

  def attendance_detail
    unless @adm.valid?
      redirect_to edit_business_admpart_path(@business, id: @adm.try(:ref_date) || Date.today)
    else

      @adm.force_refresh = params[:force_refresh] 

      @ignore_zero_income = !params[:show_zero_income]

      @contacts = @adm.contacts_in_attendance_report
    end
  end

  def edit
    @adm.force_refresh = true
  end

  def update
    if @adm.update_attributes(params[:admpart])
      redirect_to business_admpart_path(@business, @adm)
    else
      render :edit
    end
  end

  private

  # get admpart from id (current, a date or id) or from year and month
  def get_admpart
    id = params[:id] || params[:admpart_id]
    @adm = if id
       if id.to_s == "current"
         @business.current_admpart
       else
         begin
           @business.admparts.get_for_ref_date(id.to_date)
         rescue
           @business.admparts.find id
         end
       end
    elsif params[:year] && params[:month]
      @business.admparts.get_for_ref_date(Date.civil(params[:year].to_i,params[:month].to_i,1))
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
