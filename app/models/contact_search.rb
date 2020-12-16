class ContactSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business_id,
                :name,
                :teacher,
                :status,
                :membership_payment_type_id,
                :membership_status

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
    scope = Contact.where(nil)
    
    scope = scope.includes(:current_membership).references(:current_membership)

    scope = scope.where(business_id: @business_id) unless @business_id.nil?
    
    if @name.present?
      scope = scope.where("lower(contacts.name) LIKE ?", "%#{@name.downcase}%")
    end

    if @teacher.present?
      scope = scope.where(:padma_teacher => @teacher)
    end

    if @status == "student"
      scope = scope.where("contacts.padma_status = 'student' OR (contacts.padma_status IS NULL AND memberships.id IS NOT NULL AND memberships.closed_on IS NULL)")
    elsif @status == "former_student"
      scope = scope.where(:padma_status => "former_student")
    end

    ## FILTER BY membership payment_type_id
    if @membership_payment_type_id
      @membership_payment_type_id = [@membership_payment_type_id] unless @membership_payment_type_id.is_a?(Array)
      @membership_payment_type_id.reject!(&:empty?)
      scope = scope.where(:current_membership => {payment_type_id: @membership_payment_type_id}) unless @membership_payment_type_id.empty? || @membership_payment_type_id.include?('all')
    end


    ## FILTER BY membership_status
    @membership_status = [@membership_status] unless @membership_status.is_a?(Array)
    ms_queries_to_or = []
    ms_vars = {}
    @membership_status.each do |ms|
      case ms
      when "due"
        ms_queries_to_or << "(memberships.closed_on IS NULL AND memberships.ends_on > :due_ends_on_gt AND memberships.ends_on <= :due_ends_on_lte)"
        ms_vars.merge!({
          due_ends_on_gt: Date.today.beginning_of_month,
          due_ends_on_lte: Date.today.end_of_month
        })
      when "overdue"
        ms_queries_to_or << "(memberships.closed_on IS NULL AND memberships.ends_on <= :overdue_ends_on_lte)"
        ms_vars.merge!({
          overdue_ends_on_lte: Date.today
        })
      end
    end
    scope = scope.where(ms_queries_to_or.join("OR"), ms_vars) unless ms_queries_to_or.empty?


    scope
  end
end
