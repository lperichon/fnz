class Installment < ActiveRecord::Base
  belongs_to :membership
  belongs_to :agent
  has_many :installment_transactions
  has_many :transactions, :through => :installment_transactions

  validates :membership, :presence => true
  validates :due_on, :presence => true
  validates_datetime :due_on, :after => Date.parse("0000-01-01")
  validates :value, :presence => true

  scope :due, where("due_on BETWEEN '#{Date.today}' AND '#{Date.today.end_of_month}'")
  scope :overdue, where("due_on < '#{Date.today}'")
  scope :incomplete, where("installments.value > installments.balance")

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :agent_id, :due_on, :value, :transactions_attributes, :installment_transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :installment_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  def pending?
    !transactions.empty? && transactions.any? { |t| t.pending? }
  end

  def complete?
    balance >= value
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

    membership = business.memberships.find_by_external_id(row[4].to_i)

    return unless membership

    agent_id = membership.contact.padma_teacher
    agent = business.agents.find_by_padma_id(agent_id)
    unless agent
      agent_name = agent_id.blank? ? "Unknown" : agent_id
      agent = business.agents.create(:padma_id => agent_id, :name => agent_name)
    end

    due_on_date = Date.parse(row[2])

    installment_attributes = {
        :due_on => due_on_date,
        :value => row[1].to_f,
        :membership_id => membership.id,
        :agent_id => agent.id
    }

    unless row[3].blank? || row[3] == "false"
    	#paid installment, create correspondig transaction
    	transaction_date = row[5].present? ? Date.parse(row[5]) : due_on_date
    	transaction_attrs = {
    		:transaction_at => transaction_date,
    		:amount => row[1].to_f,
    		:source_id => business.accounts.first.id,
    		:business_id => business.id,
    		:description => "Payment - #{membership.contact.name} - #{due_on_date.strftime('%B %Y')}",
      		:type => "Credit",
      		:creator_id => business.owner_id
      	}

      	installment_attributes[:transactions_attributes] = [transaction_attrs]
    end	
    
    installment = Installment.new(installment_attributes)
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
