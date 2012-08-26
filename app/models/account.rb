class Account < ActiveRecord::Base
  belongs_to :business

  has_many :transactions, :foreign_key => :source_id

  validates :name, :presence => true
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :currency

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  def currency=(currency_code)
    self[:currency] = currency_code
  end
  def currency
    Currency.find(self[:currency]) || Currency.find(:usd)
  end

  private

  def calculate_balance
    transactions.inject(0) {|balance, transaction| balance+transaction.sign*transaction.amount}
  end
end
