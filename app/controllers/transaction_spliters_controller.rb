class TransactionSplitersController < UserApplicationController

  before_filter :get_business
  before_filter :get_transaction

  def new
    @spliter = TransactionSpliter.new(source: @transaction,
                                      targets: [@transaction,@transaction]
                                     )
  end

  def create
    @spliter = TransactionSpliter.new(params[:transaction_spliter].merge({source: @transaction}))
    @spliter.do_split!
    respond_to do |format|
      format.html { redirect_to business_transactions_path(@business) }
    end
  end

  private

  def get_business
    @business = Business.find params[:business_id]
  end

  def get_transaction
    @transaction = @business.transactions.find(params[:transaction_id])
  end
end
