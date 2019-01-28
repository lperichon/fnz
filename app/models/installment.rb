class Installment < ActiveRecord::Base
  belongs_to :membership, :touch => true
  belongs_to :agent
  has_many :installment_transactions
  has_many :transactions, :through => :installment_transactions

  attr_accessor :installments_count
  attr_accessor :agent_padma_id

  validates :membership, :presence => true
  validates :due_on, :presence => true
  validates_datetime :due_on, :after => Date.parse("0001-01-01")
  validates :value, :presence => true

  scope :due, where("due_on BETWEEN '#{Date.today}' AND '#{Date.today.end_of_month}'")
  scope :overdue, where("due_on < '#{Date.today}'")
  scope :incomplete, where(:status => :incomplete)

  default_scope order("due_on DESC")

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :agent_id, :due_on, :value, :transactions_attributes, :installment_transactions_attributes, :external_id, :observations, :status, :balance, :installments_count, :agent_padma_id, :transaction_ids
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :installment_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  before_save :refresh_status

  before_save :set_agent

  # @example Installment.for_contact_on_month(contact_id: 123, ref_date: Date.today)
  def self.for_contact(contact_id)
    self.joins(:membership).where(
      membership: {
        contact_id: contact_id
      }
    )
  end

  def self.on_business(business_id)
    self.joins(:membership).where(
      membership: {
        business_id: business_id
      }
    )
  end

  def self.on_month(ref_date)
    self.where(due_on: (ref_date.beginning_of_month..ref_date.end_of_month))
  end

  def self.last_updated_at(business_id)
    Installment.unscoped.joins(:membership).where(memberships: { business_id: business_id }).select("max(installments.updated_at) as last_update").group("memberships.business_id").order("last_update asc").last.last_update
  end
  
  def set_agent
    self.agent = self.membership.business.agents.find_by_padma_id(self.agent_padma_id) if self.agent_padma_id.present?
  end

  def status
    self.update_status if self[:status].blank?
    self[:status].to_sym
  end

  def pending?
    status.to_sym == :pending
  end

  def complete?
    status.to_sym == :complete
  end

  def refresh_status
    status = calculate_status
  end

  def update_balance_and_status 
    self.balance = calculate_balance
    self.status = calculate_status
    save
  end

  def update_status
    self.update_attribute(:status, calculate_status)
  end

  def update_balance
    self.update_attribute(:balance, calculate_balance)
  end

  def self.build_from_csv(business, row)

    return if Installment.find_by_external_id(row[0].to_i)

    membership = business.memberships.find_by_external_id(row[4].to_i)

    return unless membership

    agent_id = membership.contact.padma_teacher
    agent = business.agents.find_by_padma_id(agent_id)
    unless agent
      agent_name = agent_id.blank? ? "Unknown" : agent_id.gsub('.',' ').titleize
      agent = business.agents.create(:padma_id => agent_id, :name => agent_name)
    end

    due_on_date = Date.parse(row[2])

    installment_attributes = {
        :due_on => due_on_date,
        :value => row[1].to_f,
        :membership_id => membership.id,
        :agent_id => agent.id,
        :external_id => row[0].to_i
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

  def calculate_status
    if calculate_pending
      :pending
    elsif calculate_complete
      :complete
    elsif DateTime.now >= due_on
      :overdue
    else
      :incomplete
    end
  end

  def calculate_pending
    !transactions.empty? && transactions.any? { |t| t.pending? }
  end

  def calculate_complete
    balance >= value
  end

end
