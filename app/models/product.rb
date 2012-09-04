class Product < ActiveRecord::Base
  belongs_to :business

  validates :name, :presence => true
  validates :price, :presence => true, :numericality => {:greater_than => 0}
  validates :business, :presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :business_id, :price, :currency

  def currency=(currency_code)
    self[:currency] = currency_code
  end
  def currency
    Currency.find(self[:currency]) || Currency.find(:usd)
  end
end
