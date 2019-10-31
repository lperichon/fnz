class BalanceCheck < ActiveRecord::Base
  attr_accessible :account_id, :balance_cents, :checked_at, :balance

  belongs_to :account
  belongs_to :creator, :class_name => "User"

  belongs_to :difference_transaction, dependent: :destroy, class_name: "Transaction"

  before_validation :set_creator

  validate :balance, presence: true
  validate :account, presence: true

  before_create :create_difference_transaction

  after_save :set_accounts_balance
  around_destroy :set_accounts_balance_around_destroy

  def balance
    balance_cents.nil?? nil : balance_cents/100.0
  end

  def balance=(new_balance)
    self.balance_cents = (new_balance.nil?? nil : new_balance.to_f*100)
  end

  private 

  def create_difference_transaction
    if balance && account
      diff = balance - account.balance    
      self.difference_transaction = Transaction.create!(
        type: (diff > 0)? "Credit" : "Debit",
        amount: diff.abs,
        state: "created",
        transaction_at: checked_at,
        source_id: account_id,
        business_id: account.business_id,
        description: _("Diferencia de caja (balance: %{balance})") % { balance: balance }
      )
    end
  end

  def set_creator
    self.creator = User.current_user unless creator
  end

  def set_accounts_balance
    if account_id_was != account_id
      Account.find(account_id_was).update_balance if account_id_was
    end
    account.update_balance
  end

  def set_accounts_balance_around_destroy
    cached_account = account
    yield
    cached_account.update_balance if cached_account
  end
  
end
