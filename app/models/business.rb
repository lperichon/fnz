class Business < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :accounts
  has_many :transactions
  has_many :tags
  has_many :contacts
  has_many :agents
  has_many :products
  has_many :imports
  has_many :payment_types
  has_and_belongs_to_many :users

  validates :name, :presence => true
  validates :owner, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :type, :name, :owner_id, :padma_id, :synchronized_at

  after_save :link_to_owner

  def link_to_owner
    unless(self.owner.business_ids.include?(self.id))
      self.owner.businesses << self
    end
  end

  def padma
    PadmaAccount.find(padma_id) if padma_id
  end
end
