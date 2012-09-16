class Installment < ActiveRecord::Base
  belongs_to :membership
  has_and_belongs_to_many :transactions

  validates :membership, :presence => true

  validates :due_on, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :due_on, :transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
end
