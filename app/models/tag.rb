class Tag < ActiveRecord::Base
  belongs_to :business

  validates :keyword, :presence => true
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :keyword, :business_id
end
