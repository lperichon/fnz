class MembershipStats
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

  def credited_enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => 'created').where("transaction_at >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def reconciled_enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => 'reconciled').where("reconciled_at >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND reconciled_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def pending_enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => 'pending').where("transaction_at >= '#{Date.new(year, month, 1).beginning_of_month.beginning_of_day}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def credited_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => 'created').where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > installments.value THEN installments.value ELSE transactions.amount END) AS sum")
  end

  def reconciled_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => 'reconciled').where("reconciled_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND reconciled_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > installments.value THEN installments.value ELSE transactions.amount END) AS sum")
  end

  def pending_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => 'pending').where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month.beginning_of_day}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount > installments.value THEN installments.value ELSE transactions.amount END) AS sum")
  end
end
