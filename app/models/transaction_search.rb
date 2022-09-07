class TransactionSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business_id,
    :smart_meta_period,
    :transacted_at_meta_period,
    :reconciled_at_meta_period,
    :report_at_meta_period,
    :source_account_id,
    :type,
    :description,
    :amount_gte,
    :amount_lte,
    :state,
    :contact_id,
    :admpart_tag_id,
    :base_scope,
    :recurrent_transaction_id,
    :ids

  def initialize(attributes = {})
    attributes.each do |name,value|
      if value.is_a?(Array)
        value = value.reject(&:blank?)
      end
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def base_scope
    @base_scope || Transaction
  end

  def results
    scope = @base_scope.where(business_id: business_id)

    scope = scope_by_ids(scope)

    scope = scope_to_smart_meta_period(smart_meta_period, scope) if smart_meta_period.present?
    scope = scope_to_meta_period(:transaction_at, transacted_at_meta_period, scope) if  transacted_at_meta_period.present?
    scope = scope_to_meta_period(:reconciled_at, reconciled_at_meta_period, scope) if  reconciled_at_meta_period.present?
    scope = scope_to_meta_period(:report_at, report_at_meta_period, scope) if report_at_meta_period.present?

    scope = scope.where("LOWER(description) like ?", "%#{description.downcase}%") if description.present?
    scope = scope_to_accounts(scope)
    scope = scope.where(type: type) if type.present?
    scope = scope.where(state: state) if state.present?
    scope = scope.where("amount_cents >= ?", (amount_gte*100).to_i) if amount_gte.present?
    scope = scope.where("amount_cents <= ?", (amount_lte*100).to_i) if amount_lte.present?

    scope = scope.where(contact_id: contact_id) if contact_id.present?
    scope = scope.where(admpart_tag_id: admpart_tag_id) if admpart_tag_id.present?

    scope = scope.where(recurrent_transaction_id: recurrent_transaction_id) if recurrent_transaction_id.present?

    scope
  end

  def scope_to_accounts(scope)
    if source_account_id.present?
      scope = if source_account_id.is_a?(Array)
        scope.where(source_id: source_account_id.reject{|aid| aid.blank?})
      else
        scope.where(source_id: source_account_id)
      end
    end
    scope
  end

  def scope_by_ids(scope)
    scope = scope.where(id: ids) if ids.present?
    scope
  end

  def scope_to_smart_meta_period(meta_period, scope)
    left = period_left(meta_period)
    right = period_right(meta_period)
    scope.where("(transaction_at >= :start AND transaction_at <= :end) OR (state = 'pending' AND transaction_at <= :start) OR (state = 'reconciled' AND reconciled_at >= :start AND reconciled_at <= :end)", {start: left.to_time, end: right.to_time})
  end

  def scope_to_meta_period(field, meta_period, scope)
    if meta_period.present?
      scope = scope.where(field => period_left(meta_period).. period_right(meta_period))
    end
    scope
  end

  def period_left(meta_period)
    case meta_period
      when "current_month"
        Time.zone.today.beginning_of_month.beginning_of_day
      when "previous_month"
        1.month.ago.beginning_of_month.beginning_of_day
      when "month_before_last"
        2.month.ago.beginning_of_month.beginning_of_day
    end
  end

  def period_right(meta_period)
    case meta_period
      when "current_month"
        Time.zone.today.end_of_month.end_of_day
      when "previous_month"
        1.month.ago.end_of_month.end_of_day
      when "month_before_last"
        2.month.ago.end_of_month.end_of_day
    end
  end

  def period_filter?
    smart_meta_period || transacted_at_meta_period || reconciled_at_meta_period || report_at_meta_period
  end

end
