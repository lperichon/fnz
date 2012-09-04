class Sale < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  belongs_to :agent

  has_and_belongs_to_many :transactions

  validates :business, :presence => true
  validates :agent, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :contact_id, :business_id, :agent_id, :transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
end
