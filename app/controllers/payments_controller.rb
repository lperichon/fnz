class PaymentsController < UserApplicationController

  before_filter :get_context

  def new
    @installment = @membership.installments.find(params[:installment_id]) if params[:installment_id]
    @enrollment = @membership.enrollment if request.path.include?("enrollment")
    @sale = @business.sales.find(params[:sale_id]) if params[:sale_id]
    @transaction = @business.transactions.new(params[:transaction])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    default_payment_attributes = {}

    if params[:installment_id] && @installment = @membership.installments.find(params[:installment_id])
      default_payment_attributes = {
        :installment_ids => [@installment.id],
        :description => "Installment Payment - #{@membership.contact.name} - #{@installment.due_on.strftime('%B %Y')}",
        :type => "Credit",
        :amount => @installment.value
      }
      @redirect_url = session.delete(:return_to) || overview_business_memberships_path(@business)
    elsif request.path.include?("enrollment") && @enrollment = @membership.enrollment
      default_payment_attributes = {
        :enrollment_ids => [@enrollment.id],
        :description => "Enrollment Payment - #{@membership.contact.name}",
        :type => "Credit",
        :amount => @enrollment.value
      }
      @redirect_url = business_membership_enrollment_path(@business,@membership)
    elsif params[:sale_id] && @sale = @business.sales.find(params[:sale_id])
      default_payment_attributes = {
        :sale_ids => [@sale.id],
        :description => "Sale Payment - Contact:#{@sale.try(:contact).try(:name)} - Product: #{@sale.try(:product).try(:name)} - Agent: #{@sale.try(:agent).try(:name)}",
        :type => "Credit",
        :amount => @sale.try(:product).try(:price)
      }
      @redirect_url = business_sale_path(@business, @sale)
    end

    @transaction = @business.transactions.new(params[:transaction].merge(default_payment_attributes))
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
