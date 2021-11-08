class SaleStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year

  validates :business, :month, :year, :presence => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def all_sales
    business.sales.joins(:transactions).where("sold_on >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND sold_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'")
  end

  def paid_sales
    business.sales.joins(:transactions).where("transactions.report_at >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND transactions.report_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'")
  end
end
