class ClosuresController < UserApplicationController
  before_filter :get_business

  layout 'application_without_sidebar'

  def index
    case @business.type
    when School
      #get businesses closures
      #@closures = @business.closures
    end
  end

  def show
    if params[:id].present?
      @closure = @business.closures.find(params[:id])
    else
      @closure = EventClosure.new @business
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

end
