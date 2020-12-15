class BalanceChecksController < UserApplicationController

  before_filter :get_business
  before_filter :get_account

  def index
    @balance_checks = @account.balance_checks.order("checked_at DESC")
  end

  def show
    @balance_check = BalanceCheck.find(params[:id])
    @transactions = @balance_check.transactions
    render layout: "application_without_sidebar"
  end

  def new
    @balance_check = @account.balance_checks.build(
      checked_at: Time.zone.now
    )
  end

  def create
    @balance_check = @account.balance_checks.create(balance_check_params)
    @account.reload
  end

  def destroy
    @balance_check = @account.balance_checks.find(params[:id]).destroy
  end

  private

  def get_business
    @business = Business.find(params[:business_id])
  end

  def get_account
    @account = @business.accounts.find(params[:account_id])
  end
  
  def balance_check_params
    params.require(:balance_check).permit(
      :account_id,
      :balance_cents,
      :checked_at,
      :balance
    ) if params[:balance_check].present?
  end
end
