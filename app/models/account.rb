class Account < ActiveRecord::Base
  belongs_to :business

  has_many :transactions, :foreign_key => :source_id

  validates :name, :presence => true
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id
end
