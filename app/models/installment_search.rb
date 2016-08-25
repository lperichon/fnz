class InstallmentSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :due_after, :due_before, :status, :business_id, :agent_id,
                :payment_type_id

  def initialize(attributes = {})
    attributes ||= {}
    attributes.each do |name,value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def results
    scope = Installment.scoped

    scope = scope.joins(:membership) if @business_id || @payment_type_id

    scope = scope.where('memberships.business_id' => @business_id) unless @business_id.nil?
    scope = scope.where("due_on >= ?", @due_after) unless @due_after.nil?
    scope = scope.where("due_on <= ?", @due_before) unless @due_before.nil?
    scope = scope.where(:status => @status) unless @status.nil?
    scope = scope.where(:agent_id => @agent_id) unless @agent_id.nil? || @agent_id.include?('all')
    scope = scope.where(memberships: { payment_type_id: payment_type_id }) unless @payment_type_id.blank?

    scope
  end
end
