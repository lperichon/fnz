class Installment < ActiveRecord::Base
  belongs_to :membership

  validates :membership, :presence => true

  validates :due_on, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :membership_id, :due_on
end
