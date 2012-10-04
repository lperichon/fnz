class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :memberships

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id

  def membership
    membership = memberships.first
    membership unless membership.try(:closed_on)
  end
end
