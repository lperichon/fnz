class Contact < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  has_many :memberships

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id

  def membership
    memberships.first
  end
end
