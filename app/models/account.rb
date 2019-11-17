class Account < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :business

  before_save :set_defaults

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :balance_checks

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :currency, :default

  def transactions
    Transaction.where("source_id = ? or (type='Transfer' and target_id = ?)", self.id, self.id)
  end

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  def currency=(currency_code)
    self[:currency] = currency_code
  end

  def currency
    Currency.find(self[:currency]) || Currency.find(business.currency_code) || Currency.find(:usd)
  end

  def last_balance_check
    @last_balance_check ||= balance_checks.order(:checked_at).last
  end

  # transactions considered in balance calculation
  def active_transactions
    if last_balance_check
      from = last_balance_check.checked_at
      transactions.where("
                         ((state = 'created') AND (transaction_at > ?))
                         OR
                         ((state = 'reconciled') AND (reconciled_at > ?))",
                         from, from)
    else
      transactions.where(:state => ['created', 'reconciled'])
    end
  end

  private

  def set_defaults
    self.currency = business.currency_code if self.currency.nil?
  end

  def calculate_balance
    base = last_balance_check.nil?? 0 : last_balance_check.balance
    
    active_transactions.inject(base) do |balance, transaction|
      balance+transaction.sign(self)*transaction.amount
    end
  end
end
