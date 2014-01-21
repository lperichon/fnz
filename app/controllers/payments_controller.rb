class PaymentsController < UserApplicationController

  before_filter :get_context

  def new
    @installment = @context.find(params[:installment_id])
    @transaction = @business.transactions.new(params[:transaction])
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @installment = @context.find(params[:installment_id])
    
    default_payment_attributes = {
      :installment_ids => [@installment.id],
      :description => "Payment - #{@membership.contact.name} - #{@installment.due_on.strftime('%B %Y')}",
      :type => "Credit",
      :amount => @installment.value
    }

    @transaction = @business.transactions.new(params[:transaction].merge(default_payment_attributes))
    respond_to do |format|
      if @transaction.save
        format.js {}
      else
        format.js {}
      end
    end
  end

  private

  def get_context
    @business = current_user.businesses.find(params[:business_id])
    @membership = @business.memberships.find(params[:membership_id])
    @context = @membership.installments
  end

end
