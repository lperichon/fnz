class Business < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"

  validates :name, :presence => true
  validates :owner, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :owner_id
end
