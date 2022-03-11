class RecurrentTransactionsController < UserApplicationController

  before_filter :get_business

  def index
    @recurrent_transactions = @business.recurrent_transactions
  end

  def new

  end

  def create
    @recurrent_transaction = @business.recurrent_transactions.new(recurrent_transaction_params)

    respond_to do |format|
      if @recurrent_transaction.save!
        format.html { redirect_to business_recurrent_transactions_path(business_id: @business), notice: _('Movimiento creado') }
        format.json { render json: @recurrent_transaction, status: :created, location: business_recurrent_transaction_path(@business, @recurrent_transactions) }
      else
        format.html { redirect_to business_recurrent_transactions_path(business_id: @business), alert: @recurrent_transaction.errors.full_messages.to_sentence }
        format.json { render json: @recurrent_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @recurrent_transaction = @business.recurrent_transactions.find(params[:id])

    respond_to do |format|
      if @recurrent_transaction.update_attributes(recurrent_transaction_params || {})
        format.html { redirect_to business_recurrent_transactions_path(@business), notice: _("Movimiento recurrente actualizado") }
        format.js {}
        format.json do
          respond_with_bip(@recurrent_transaction.becomes(RecurrentTransaction), param: param_key)
        end
      else
        format.html { render action: "edit" }
        format.js {}
        format.json { respond_with_bip(@recurrent_transaction.becomes(RecurrentTransaction), param: param_key) }
      end
    end
  end

  def destroy
    @recurrent_transaction = @business.recurrent_transactions.find(params[:id])
    @recurrent_transaction.destroy
    redirect_to business_recurrent_transactions_path(business_id: @business.id)
  end

  private

  def get_business
    @business ||= Business.find(params[:business_id])
  end

  def param_key
    if params[:recurrent_credit]
      :recurrent_credit
    elsif params[:recurrent_debit]
      :recurrent_debit
    else
      :recurrent_transaction
    end
  end

  def recurrent_transaction_params
    params.require(param_key).permit(
      :description,
      :business_id,
      :source_id,
      :amount,
      :type,
      :target_id,
      :state,
      :contact_id,
      :agent_id,
      :admpart_tag_id
    ) if params[param_key].present?
  end

end
