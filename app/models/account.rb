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
    ret = Currency.find(self[:currency])
    if ret.nil? && business
      ret = Currency.find(business.currency_code)
    end
    if ret.nil?
      ret = Currency.find(:usd)
    end
    ret
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

  def current_balance_checked?
    active_transactions.empty?
  end

  def self.calculate_total_balance_per_currency
    ret = {}
    self.scoped.includes(:business).group_by(&:currency).each do |cur,accs|
      ret[cur.id] = accs.inject(0) do |acum, acc|
        acum + acc.balance
      end
    end
    ret
  end

  def calculate_balance(ref_date=nil)
    base = last_balance_check.nil?? 0 : last_balance_check.balance

    transactions_scope = if ref_date.nil?
      active_transactions
    else
      active_transactions.where("
                         ((state = 'created') AND (transaction_at < ?))
                         OR
                         ((state = 'reconciled') AND (reconciled_at < ?))",
                         ref_date, ref_date)
    end

    
    transactions_scope.inject(base) do |balance, transaction|
      balance+transaction.sign(self)*transaction.amount
    end
  end

  private

  def set_defaults
    self.currency = business.currency_code if self.currency.nil?
  end
end
