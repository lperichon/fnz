class Business < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :accounts
  has_many :transactions
  has_many :tags
  has_many :contacts
  has_many :agents
  has_many :products
  has_many :imports

  validates :name, :presence => true
  validates :owner, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :type, :name, :owner_id
end
