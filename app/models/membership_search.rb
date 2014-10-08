class MembershipSearch
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :ends_after, :ends_before

  def initialize(attributes = {})
    attributes.each do |name,value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def results
    scope = Membership.scoped
    
    scope = scope.where("ends_on >= ?", @ends_after) unless @ends_after.nil?
    scope = scope.where("ends_on <= ?", @ends_before) unless @ends_before.nil?

    scope
  end
end
