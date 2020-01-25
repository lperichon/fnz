class TransactionSplitersController < UserApplicationController

  before_filter :get_business
  before_filter :get_transaction

  def new
    @spliter = TransactionSpliter.new(source: @transaction,
                                      targets: [@transaction,@transaction]
                                     )
  end

  def create
    render text: params.inspect
  end


  private

  def get_business
    @business = Business.find params[:business_id]
  end

  def get_transaction
    @transaction = @business.transactions.find(params[:transaction_id])
  end
end
