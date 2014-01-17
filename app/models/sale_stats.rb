class SaleStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year

  validate :business, :month, :year, :presence => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def sales
    business.sales.joins(:transactions).where("transaction_at >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'")
  end
end
