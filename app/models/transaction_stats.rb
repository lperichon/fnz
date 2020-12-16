class TransactionStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year, :context

  validate :business, :month, :year, :presence => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    # List transactions on this month or the year/month solicited
    start_date = Date.new(year.present? ? year : Date.today.year, month.present? ? month.to_i : (year.present? ? 1 : Date.today.month), 1).beginning_of_month.beginning_of_day
    end_date = Date.new(year.present? ? year : Date.today.year, month.present? ? month : (year.present? ? 12 : Date.today.month), 28).end_of_month.end_of_day

    # List transactions that ocurred on that month or that are pending and ocurred before or that are reconciled on that month
    @context = business.trans.where {(transaction_at.gteq start_date) & (transaction_at.lteq end_date)}
  end

  def persisted?
    false
  end

  def debits
    context.where(:type => "Debit").joins(:tags).group('tags.name').sum(:amount)
  end

  def untagged_debits
    context.where(:type => "Debit").untagged.sum(:amount)
  end

  def credits
    context.where(:type => "Credit").joins(:tags).group('tags.name').sum(:amount)
  end

  def untagged_credits
    context.where(:type => "Credit").untagged.sum(:amount)
  end

end
