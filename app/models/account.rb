class Account < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :business

  before_save :set_defaults

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :balance_checks

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :name, :business_id, :currency, :default

  def trans
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

  def currency_code=(currency_code)
    self[:currency] = currency_code
  end

  def currency_code
    self[:currency]
  end

  def last_balance_check
    @last_balance_check ||= balance_checks.order(:checked_at).last
  end

  # transactions considered in balance calculation
  def active_transactions
    if last_balance_check
      from = last_balance_check.checked_at
      trans.where("
                         ((state = 'created') AND (transaction_at > ?))
                         OR
                         ((state = 'reconciled') AND (reconciled_at > ?))",
                         from, from)
    else
      trans.where(:state => ['created', 'reconciled'])
    end
  end

  def current_balance_checked?
    active_transactions.empty?
  end

  def self.calculate_total_balance_per_currency
    ret = {}
    self.where(nil).includes(:business).group_by(&:currency).each do |cur,accs|
      ret[cur.id] = accs.inject(0) do |acum, acc|
        acum + acc.balance
      end
    end
    ret
  end

  def self.calculate_pending_balance_per_currency
    ret = {}
    self.where(nil).includes(:business).group_by(&:currency).each do |cur,accs|
      ret[cur.id] = accs.inject(0) do |acum, acc|
        acc_bal = acc.trans.where(state: "pending").inject(0) do |bal,t|
          bal+t.amount*t.sign(acc)
        end
        acum + acc_bal
      end
    end
    ret
  end

  def calculate_balance(ref_time=nil)
    base = if ref_time.nil?
      last_balance_check.nil?? 0 : last_balance_check.balance
    else
      bc = balance_checks.order(:checked_at)
                         .where("checked_at < ?",ref_time)
                         .last
      bc.nil?? 0 : bc.balance
    end

    transactions_scope = if ref_time.nil?
      active_transactions
    else
      active_transactions.where("
                         ((state = 'created') AND (transaction_at < ?))
                         OR
                         ((state = 'reconciled') AND (reconciled_at < ?))",
                         ref_time, ref_time)
    end


    transactions_scope.inject(base) do |balance, transaction|
      balance+transaction.sign(self)*transaction.amount
    end
  end

  def self.default
    where(default: true).first
  end

  private

  def set_defaults
    self.currency = business.currency_code if self.currency.nil?
  end
end
