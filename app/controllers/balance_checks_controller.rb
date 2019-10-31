class BalanceChecksController < UserApplicationController

  before_filter :get_business
  before_filter :get_account

  def index
    @balance_checks = @account.balance_checks
  end

  def new
    @balance_check = @account.balance_checks.build(
      checked_at: Time.zone.now
    )
  end

  def create
    @balance_check = @account.balance_checks.create(params[:balance_check])
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
  
end
