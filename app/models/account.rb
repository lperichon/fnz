class Account < ActiveRecord::Base
  belongs_to :business

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
    Currency.find(self[:currency]) || Currency.find(:usd)
  end

  private

  def calculate_balance
    transactions.where(:state => ['created', 'reconciled']).inject(0) {|balance, transaction| balance+transaction.sign(self)*transaction.amount}
  end
end
