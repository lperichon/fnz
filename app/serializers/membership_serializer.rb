class MembershipSerializer < ActiveModel::Serializer
  attributes :value, :begins_on, :ends_on, :payment_type
  has_many :installments

  def payment_type
  	object.payment_type.try(:name)
  end
end