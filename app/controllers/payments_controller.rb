class PaymentsController < UserApplicationController

  before_filter :get_context

  def new
    @installment = @membership.installments.find(params[:installment_id]) if params[:installment_id]
    @enrollment = @membership.enrollment if request.path.include?("enrollment")
    @transaction = @business.transactions.new(params[:transaction])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    default_payment_attributes = {}

    if params[:installment_id] && @installment = @membership.installments.find(params[:installment_id])
      default_payment_attributes = {
        :installment_ids => [@installment.id],
        :description => "Payment - #{@membership.contact.name} - #{@installment.due_on.strftime('%B %Y')}",
        :type => "Credit",
        :amount => @installment.value
      }
      @redirect_url = overview_business_memberships_path(@business)
    elsif request.path.include?("enrollment") && @enrollment = @membership.enrollment
      default_payment_attributes = {
        :enrollment_ids => [@enrollment.id],
        :description => "Payment - #{@membership.contact.name} - Enrollment",
        :type => "Credit",
        :amount => @enrollment.value
      }
      @redirect_url = business_membership_enrollment_path(@business,@membership)
    end

    @transaction = @business.transactions.new(params[:transaction].merge(default_payment_attributes))
    @transaction.save
  end

  private

  def get_context
    @business = current_user.businesses.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id])
  end

end
