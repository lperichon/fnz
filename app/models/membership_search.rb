class MembershipSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :ends_after, :ends_before, :business_id, :payment_type_id, :status, :contact_name, :contact_teacher, :contact_status

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
    scope = Membership.where(nil)

    scope = scope.where(business_id: @business_id) unless @business_id.nil?
    if @status == "due"
      scope = scope.where("closed_on IS NULL AND ends_on > ? AND ends_on <= ?", Date.today.beginning_of_month, Date.today.end_of_month)
    elsif @status == "overdue"
      scope = scope.where("closed_on IS NULL AND ends_on <= ?", Date.today)
    end

    if @contact_name.present?
      scope = scope.includes("contact").references("contact").where("contacts.name LIKE ?", "%#{@contact_name}%")
    end

    if @contact_teacher.present?
      scope = scope.includes("contact").where(:contacts => {:padma_teacher => @contact_teacher})
    end

    if @contact_status == "student"
      scope = scope.includes(:contact).where(:contacts => {:padma_status => [nil, "student"]})
    elsif @contact_status == "former_student"
      scope = scope.includes("contact").where(:contacts => {:padma_status => [nil, "former_student"]})
    end

    scope = scope.where("(closed_on IS NULL AND ends_on >= :ends_after_date) OR (closed_on >= :ends_after_date)", ends_after_date: @ends_after) unless @ends_after.nil?
    scope = scope.where("ends_on <= ?", @ends_before) unless @ends_before.nil?
    scope = scope.where(payment_type_id: @payment_type_id) unless @payment_type_id.blank? || (@payment_type_id.class == "Array" && @payment_type_id.include?('all'))

    scope
  end
end
