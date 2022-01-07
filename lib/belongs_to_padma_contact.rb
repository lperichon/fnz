module BelongsToPadmaContact #:nodoc:
  extend ActiveSupport::Concern

  included do
    #attr_accessible :padma_contact_id

    def padma_contact_id= padma_contact_id
      return if padma_contact_id.blank?
      c = Contact.where(business_id: self.business_id).get_by_padma_id(padma_contact_id)
      self.contact = c
    end

    def padma_contact_id
      self.contact.try(:padma_id)
    end
  end
end
