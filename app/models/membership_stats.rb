class MembershipStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year

  validates_presence_of :business, :month, :year

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where("enrolled_on >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND enrolled_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where("due_on >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND due_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > installments.value THEN installments.value ELSE transactions.amount END) AS sum")
  end
end
