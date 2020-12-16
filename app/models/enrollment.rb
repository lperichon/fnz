class Enrollment < ActiveRecord::Base
  belongs_to :membership
  belongs_to :agent
  has_many :enrollment_transactions
  has_many :trans, foreign_key: 'transaction_id', class_name: "Transaction", :through => :enrollment_transactions

  validates :membership, :presence => true
  validates :agent, :presence => true
  validates :value, :presence => true
  validates :enrolled_on, :presence => true

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :membership_id, :agent_id, :value, :enrolled_on, :transactions_attributes, :enrollment_transactions_attributes
  accepts_nested_attributes_for :trans, allow_destroy: true
  accepts_nested_attributes_for :enrollment_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

  scope :this_month, -> { where {(enrolled_on.gteq Date.today.beginning_of_month.beginning_of_day) & (enrolled_on.lteq Date.today.end_of_month.end_of_day)} }

  def pending?
    !trans.empty? && trans.any? { |t| t.pending? }
  end

  def complete?
    !trans.empty? && trans.all? { |t| t.created? || t.reconciled? }
  end

  def status
    if pending?
      :pending
    elsif complete?
      :complete
    else
      :incomplete
    end
  end
end
