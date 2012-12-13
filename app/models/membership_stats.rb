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
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => :created).where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end

  def reconciled_enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => :reconciled).where("reconciled_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND reconciled_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end

  def pending_enrollments
    business.memberships.joins(:enrollment).joins(:enrollment => :transactions).where('transactions.state' => :pending).where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end

  def credited_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => :created).where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end

  def reconciled_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => :reconciled).where("reconciled_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND reconciled_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end

  def pending_installments
    business.memberships.joins(:installments).joins(:installments => :transactions).where('transactions.state' => :pending).where("transaction_at >= '#{Date.new(year, month, 1).to_date.beginning_of_month}' AND transaction_at <= '#{Date.new(year, month, 1).end_of_month}'")
  end
end
