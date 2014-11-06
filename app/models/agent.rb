class Agent < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :padma_id

  scope :disabled, where(:disabled => true)
  scope :enabled, where(:disabled => false)
end
