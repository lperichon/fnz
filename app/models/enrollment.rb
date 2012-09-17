class Enrollment < ActiveRecord::Base
  belongs_to :membership
  belongs_to :agent
  has_and_belongs_to_many :transactions

  validates :membership, :presence => true
  validates :agent, :presence => true
  validates :value, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :agent_id, :value, :transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
end
