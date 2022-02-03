class TransactionSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business_id,
    :transacted_at_meta_period,
    :reconciled_at_meta_period,
    :report_on_meta_period,
    :source_account_id,
    :type,
    :description,
    :amount_gte,
    :amount_lte,
    :state,
    :base_scope

  def initialize(attributes = {})
    attributes.each do |name,value|
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

    scope = scope_to_meta_period(:transacted_at, transacted_at_meta_period, scope) if  transacted_at_meta_period.present?
    scope = scope_to_meta_period(:reconciled_at, reconciled_at_meta_period, scope) if  reconciled_at_meta_period.present?
    scope = scope_to_meta_period(:report_on, report_on_meta_period, scope) if report_on_meta_period.present?
    scope = scope.where("description like ?", "%#{description}%") if description.present?
    scope = scope_to_accounts(scope)
    scope = scope.where(type: type) if type.present?
    scope = scope.where(state: state) if state.present?
    scope = scope.where("amount >= ?", amount_gte) if amount_gte.present?
    scope = scope.where("amount <= ?", amount_lte) if amount_lte.present?

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

  def scope_to_meta_period(field, meta_period, scope)
    if meta_period.present?
      scope = case meta_period
        when "current_month"
          scope.where(field => Time.zone.today.beginning_of_month.beginning_of_day..Time.zone.today.end_of_month.end_of_day)
      end
    end
    scope
  end
end
