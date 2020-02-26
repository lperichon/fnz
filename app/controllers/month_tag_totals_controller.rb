class MonthTagTotalsController < UserApplicationController

  layout "application_without_sidebar"

  before_filter :get_business

  def index
    @start_at = Date.civil(2019,11,1)
    end_at = Date.today.end_of_month

    @totals = {}
    i = @start_at
    while i < end_at
      @totals[i] = {}
      Admpart::VALID_SECTIONS.each do |section|
        @totals[i][section] = {}
        aux = Admpart.new
        aux.business = @business
        aux.root_tags_for_section(section).each do |tag|
          @totals[i][section][tag] = tag.month_total(i)
        end
      end

      i += 1.month
    end

    respond_to do |format|
      format.html
      format.csv do 
        headers['Content-Disposition'] = "attachment; filename=\"month_tag_totals.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  private

  def get_business
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
