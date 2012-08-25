class Transaction < ActiveRecord::Base
  after_save :update_source_balance

  belongs_to :business
  belongs_to :source, :class_name => "Account"
  belongs_to :creator, :class_name => "User"

  validates :description, :presence => true
  validates :business, :presence => true
  validates :source, :presence => true
  validates :amount, :presence => true, :numericality => {:greater_than => 0}
  validates :creator, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :description, :business_id, :source_id, :amount, :type, :transaction_at, :creator_id

  def update_source_balance
    source.update_balance
  end
end
