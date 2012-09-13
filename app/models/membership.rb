class Membership < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  has_many :installments

  validates :business, :presence => true
  validates :contact, :presence => true
  validates :begins_on, :presence => true
  validates :ends_on, :presence => true
  validates_datetime :ends_on, :after => :begins_on

  # Setup accessible (or protected) attributes for your model
  attr_accessible :contact_id, :business_id, :begins_on, :ends_on
end
