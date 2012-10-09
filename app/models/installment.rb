class Installment < ActiveRecord::Base
  belongs_to :membership
  belongs_to :agent
  has_many :installment_transactions
  has_many :transactions, :through => :installment_transactions

  validates :membership, :presence => true
  validates :agent, :presence => true
  validates :due_on, :presence => true
  validates :value, :presence => true

  scope :due, where("due_on BETWEEN '#{Date.today}' AND '#{15.days.from_now}'")
  scope :overdue, where("due_on < '#{Date.today}'")
  scope :incomplete, where("installments.value > installments.balance")

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :agent_id, :due_on, :value, :transactions_attributes, :installment_transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :installment_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  private

  def calculate_balance
    transactions.where(:state => [:created, :reconciled]).inject(0) {|balance, transaction| balance+transaction.sign(self)*transaction.amount}
  end
end