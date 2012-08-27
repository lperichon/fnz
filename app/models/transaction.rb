class Transaction < ActiveRecord::Base
  include ActiveModel::Transitions

  after_save :update_balances

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :creator, :class_name => "User"

  validates :description, :presence => true
  validates :business, :presence => true
  validates :source, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than => 0}
  validates :creator, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :description, :business_id, :source_id, :amount, :type, :transaction_at, :creator_id, :target_id, :conversion_rate, :state, :reconciled_at

  def update_balances
    source.update_balance
  end

  state_machine do
    state :created # first one is initial state
    state :pending
    state :reconciled

    event :reconcile, :timestamp => true do
      transitions :to => :reconciled, :from => :pending
    end
  end
end
