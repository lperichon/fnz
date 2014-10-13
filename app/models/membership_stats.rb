class MembershipStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year, :membership_filter

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
    memberships.joins(:enrollment).joins(:enrollment => :transactions).where("enrolled_on >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND enrolled_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def installments
    memberships.joins(:installments).joins(:installments => :transactions).where("due_on >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND due_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > installments.value THEN installments.value ELSE transactions.amount END) AS sum")
  end

  def memberships
    @memberships = Membership.where(business_id: business.id)
    unless @membership_filter.nil?
      @memberships = @memberships.where(@membership_filter)
    end
    @memberships
  end
end
