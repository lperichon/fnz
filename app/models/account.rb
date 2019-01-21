class Account < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :business

  before_save :set_defaults

  validates :name, :presence => true
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :currency

  def transactions
    Transaction.where("source_id = ? or target_id = ?", self.id, self.id)
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

  private

  def set_defaults
    self.currency = business.currency_code if self.currency.nil?
  end

  def calculate_balance
    transactions.where(:state => ['created', 'reconciled']).inject(0) {|balance, transaction| balance+transaction.sign(self)*transaction.amount}
  end
end
