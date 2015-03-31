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
    memberships.unscoped.joins(:enrollment).joins(:enrollment => :transactions).where("enrolled_on >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND enrolled_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount >= enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def all_installments
    memberships.unscoped.joins(:installments).where("due_on >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND due_on <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(installments.value) AS sum, AVG(installments.value) AS avg")
  end

  def paid_installments
    memberships.unscoped.joins(:installments).joins(:installments => :transactions).where("transactions.report_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND transactions.report_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN (installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS sum, AVG(CASE WHEN (installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS avg")
  end

  def memberships
    if @membership_filter.nil?
      @memberships = Membership.where(business_id: business.id)
    else
      @memberships = Membership.where(:id => @membership_filter.results.collect {|c| c.membership_ids })
    end
    @memberships
  end
end
