module BelongsToPadmaContact #:nodoc:
  extend ActiveSupport::Concern
  
  included do
    attr_accessible :padma_contact_id

    def padma_contact_id= padma_contact_id
    	return if padma_contact_id.blank?
	    unless c = Contact.where(padma_id: padma_contact_id).first
	      padma_contact = PadmaContact.find(padma_contact_id, select: [:first_name, :last_name, :status, :global_teacher_username])
	      c = Contact.create(padma_id: padma_contact_id,
	                         business_id: self.business_id,
	                         name: "#{padma_contact.first_name} #{padma_contact.last_name}",
	                         padma_status: padma_contact.status,
	                         padma_teacher: padma_contact.global_teacher_username)
	    end

	    self.contact = c
	end

	def padma_contact_id
	    self.contact.try(:padma_id)
	end
  end
end
