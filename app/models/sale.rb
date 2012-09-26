class Sale < ActiveRecord::Base
  belongs_to :business
  belongs_to :contact
  belongs_to :agent
  belongs_to :product

  has_many :sale_transactions
  has_many :transactions, :through => :sale_transactions

  validates :business, :presence => true
  validates :agent, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :contact_id, :business_id, :agent_id, :product_id, :transactions_attributes, :sale_transactions_attributes
  accepts_nested_attributes_for :transactions, allow_destroy: true
  accepts_nested_attributes_for :sale_transactions, :reject_if => proc { |s| s['transaction_id'].blank? }

end
