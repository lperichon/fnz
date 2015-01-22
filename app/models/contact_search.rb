class ContactSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business_id, :name, :teacher, :status, :membership_payment_type_id, :membership_status

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
    scope = Contact.scoped
    
    scope = scope.includes(:current_membership)

    scope = scope.where(business_id: @business_id) unless @business_id.nil?
    
    if @name.present?
      scope = scope.where("contacts.name LIKE ?", "%#{@name}%")
    end

    if @teacher.present?
      scope = scope.where(:padma_teacher => @teacher)
    end

    if @status == "student"
      scope = scope.where("contacts.padma_status = 'student' OR ((contacts.padma_status IS NULL OR contacts.padma_status = 'former_student') AND memberships.id IS NOT NULL AND memberships.closed_on IS NULL)")
    elsif @status == "former_student"
      scope = scope.where(:padma_status => "former_student")
    end

    scope = scope.where(:current_membership => {payment_type_id: @membership_payment_type_id}) unless @membership_payment_type_id.blank? || @membership_payment_type_id.include?('all')

    if @membership_status == "due"
      scope = scope.where("memberships.closed_on IS NULL AND memberships.ends_on > ? AND memberships.ends_on <= ?", Date.today.beginning_of_month, Date.today.end_of_month)
    elsif @membership_status == "overdue"
      scope = scope.where("memberships.closed_on IS NULL AND memberships.ends_on <= ?", Date.today)
    end

    scope
  end
end
