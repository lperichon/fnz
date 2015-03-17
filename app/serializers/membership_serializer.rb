class MembershipSerializer < ActiveModel::Serializer
  attributes :value, :begins_on, :ends_on, :payment_type, :padma_contact_id
  has_many :installments

  def payment_type
  	object.payment_type.try(:name)
  end

  def padma_contact_id
    object.contact.padma_id
  end
end
