class Product < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :price, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :cost, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :stock, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :business, :presence => true


  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :price, :price_currency, :cost, :cost_currency, :stock, :hidden

  scope :hidden, where(:hidden => true)

  def price_currency
    Currency.find(self[:price_currency]) || Currency.find(:usd)
  end

  def cost_currency
    Currency.find(self[:cost_currency]) || Currency.find(:usd)
  end
end
