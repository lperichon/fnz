class Installment < ActiveRecord::Base
  belongs_to :membership
  belongs_to :agent
  has_many :installment_transactions
  has_many :transactions, :through => :installment_transactions

  validates :membership, :presence => true
  validates :due_on, :presence => true
  validates :value, :presence => true

  scope :due, where("due_on BETWEEN '#{Date.today}' AND '#{Date.today.end_of_month}'")
  scope :overdue, where("due_on < '#{Date.today}'")
  scope :incomplete, where("installments.value > installments.balance")

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :agent_id, :due_on, :value, :transactions_attributes, :installment_transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :installment_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  def pending?
    transactions_sum = transactions.sum(:amount)
    transactions_sum != self.balance && transactions_sum >= self.value
  end

  def complete?
    transactions_sum = transactions.sum(:amount)
    transactions_sum == self.balance && transactions_sum >= self.value
  end

  def status
    if pending?
      :pending
    elsif complete?
      :complete
    elsif Date.today >= due_on
      :overdue
    else
      :incomplete
    end
  end

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  def self.build_from_csv(business, row)
    installment = Installment.new

    membership = business.memberships.find_by_external_id(row[4].to_i)

    return unless membership

    agent_id = membership.contact.padma_teacher
    agent = business.agents.find_by_padma_id(agent_id)
    unless agent
      agent = business.agents.create(:padma_id => agent_id)
    end

    installment.attributes = {
        :due_on => Date.parse(row[2]),
        :value => row[1].to_f,
        :membership_id => membership.id,
        :agent_id => agent.id
    }

    return installment
  end

  def self.csv_header
    "id,monto,vto,pago,plan_id,fecha_pago,notes,comprobante,accounting_date,created_at,updated_at,school_id,forma_id".split(',')
  end

  private

  def calculate_balance
    transactions.where(:state => ['created', 'reconciled']).inject(0) {|balance, transaction| balance+transaction.sign(self)*transaction.amount}
  end
end
