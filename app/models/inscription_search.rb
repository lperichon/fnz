class InscriptionSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business_id, :contact_name, :payment_type_id, :agent_padma_id

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
    scope = Inscription.scoped

    scope = scope.where(:business_id => @business_id) unless @business_id.nil?
    scope = scope.includes("contact").where("contacts.name LIKE ?", "%#{@contact_name}%") if @contact_name.present?
    scope = scope.where(payment_type_id: @payment_type_id) unless @payment_type_id.blank? || @payment_type_id.include?('all')
    scope = scope.where(padma_account: @agent_padma_id) unless @agent_padma_id.blank? || @agent_padma_id.include?('all')
    scope
  end
end
