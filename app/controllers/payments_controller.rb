class PaymentsController < UserApplicationController
  include RedirectBackHelper
  
  before_filter :get_context
  before_filter :store_location, :only => [:create]

  def new
    if params[:installment]
      @installment = @membership.installments.new(params[:installment])
    elsif params[:installment_id]
      @installment = @membership.installments.find(params[:installment_id]) 
    end
    
    if params[:transaction].present? and params[:transaction][:description].present? and @membership.blank?
      params[:transaction][:description] = "Multiple Installment Payment"
    end

    @enrollment = @membership.enrollment if request.path.include?("enrollment")
    @sale = @business.sales.find(params[:sale_id]) if params[:sale_id]
    @transaction = @business.transactions.new(params[:transaction])

    # defaults
    @transaction.transaction_at = Time.zone.now if @transaction.transaction_at.nil?
    @transaction.report_at = @transaction.transaction_at.to_date if @transaction.report_at.nil?
  end

  # POST /accounts
  # POST /accounts.json
  def create
    default_payment_attributes = {}

    if params[:installment]
      @installment = @membership.installments.create(params[:installment])
    end

    if @installment || params[:transaction][:installment_ids] || (params[:installment_id] && @installment = @membership.installments.find(params[:installment_id]))
      if params[:transaction][:installment_ids]
        default_payment_attributes = {
          :installment_ids => params[:transaction][:installment_ids],
          :type => "Credit"
        } 
	
	if @membership.present?
	  default_payment_attributes[:description] = "Multiple Installment Payment - #{@membership.contact.name}"
	else
          default_payment_attributes[:description] = "Multiple Installment Payment"
	end
      else
	default_payment_attributes = {
          :installment_ids => [@installment.id],
          :description => "Installment Payment - #{@membership.contact.name} - #{@installment.due_on.strftime('%B %Y')}",
          :type => "Credit",
          :amount => @installment.value
        }

        default_payment_attributes[:report_at] = @installment.due_on if params[:transaction][:report_at_option] == 'due_date'
      end

      @redirect_url = session.delete(:return_to) || overview_business_memberships_path(@business)
    elsif request.path.include?("enrollment") && @enrollment = @membership.enrollment
      default_payment_attributes = {
        :enrollment_ids => [@enrollment.id],
        :description => "Enrollment Payment - #{@membership.contact.name}",
        :type => "Credit",
        :amount => @enrollment.value
      }

      default_payment_attributes[:report_at] = @enrollment.enrolled_on if params[:transaction][:report_at_option] == 'due_date'

      @redirect_url = business_membership_enrollment_path(@business,@membership)
    elsif params[:sale_id] && @sale = @business.sales.find(params[:sale_id])
      default_payment_attributes = {
        :sale_ids => [@sale.id],
        :description => "Sale Payment - Contact:#{@sale.try(:contact).try(:name)} - Product: #{@sale.try(:product).try(:name)} - Agent: #{@sale.try(:agent).try(:name)}",
        :type => "Credit",
        :amount => @sale.try(:product).try(:price)
      }

      default_payment_attributes[:report_at] = @sale.sold_on if params[:transaction][:report_at_option] == 'due_date'

      @redirect_url = business_sale_path(@business, @sale)
    end

    @transaction = @business.transactions.new(params[:transaction].reverse_merge!(default_payment_attributes))
    @transaction.save
  end

  private

  def get_context
    if current_user.admin?
      @context = Business
    else
      @context = current_user.businesses
    end

    @business = @context.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id]) if params[:membership_id]
  end

end
