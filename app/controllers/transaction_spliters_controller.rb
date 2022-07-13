class TransactionSplitersController < UserApplicationController

  before_filter :get_business
  before_filter :get_transaction

  def new
    @spliter = TransactionSpliter.new(source: @transaction,
                                      targets: [@transaction,@transaction]
                                     )
  end

  def new_n_split
    @spliter = TransactionSpliter.new(source: @transaction)
  end

  def create_n_split
    @spliter = TransactionSpliter.new(params[:transaction_spliter].merge({source: @transaction}).permit!)
    @spliter.do_n_split!
    respond_to do |format|
      format.html { redirect_to business_transactions_path(@business, transaction_search: {ids: @spliter.targets.map(&:id)}) }
    end
  end

  def create
    @spliter = TransactionSpliter.new(params[:transaction_spliter].merge({source: @transaction}).permit!)
    @spliter.do_split!
    respond_to do |format|
      format.html { redirect_to business_transactions_path(@business, transaction_search: {ids: @spliter.targets.map(&:id)}) }
    end
  end

  private

  def get_business
    @business = Business.find params[:business_id]
  end

  def get_transaction
    @transaction = @business.trans.find(params[:transaction_id])
  end
end
