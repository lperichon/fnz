class AdmpartsController < UserApplicationController
  include RedirectBackHelper
  
  layout "application_without_sidebar"

  before_filter :store_current_location, only: [:show, :attendance_detail]

  before_filter :get_context
  before_filter :get_admpart, only: [:show, :edit, :update, :attendance_detail]
  
  def show
    if @adm.valid?
      unless params[:skip_refresh] || (@business.block_transactions_before && @adm.ref_date.end_of_month.to_time.end_of_day < @business.block_transactions_before)
        Rails.cache.clear # HACK [TODO] remove this and ensure refresh is correctly done
        @adm.queue_refresh_cache
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
    if @adm.update_attributes(admpart_params)
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
       elsif id.to_i.to_s == id
         @business.admparts.find id
       else
         @business.admparts.get_for_ref_date(id.to_date)
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

  def admpart_params
    params.require(:admpart).permit(
      :director_from_profit_percentage,
      :owners_percentage,
      :dir_from_owners_aft_expses_percentage,
      :agent_sale_percentage,
      :agent_enrollment_income_percentage,
      :agent_enrollment_quantity_fixed_amount,
      :agent_installments_attendance_percentage,
      :installments_tag_id,
      :enrollments_tag_id,
      :sales_tag_id,
      :ref_date
    )
  end
end
