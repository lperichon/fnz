class MessageProcessor
  def self.catch_message(key_name, data)
    return unless key_name == 'subscription_change'
    Rails.logger.debug "message 'subscription_change'"
    business = Business.find_by_padma_id(data[:account_name])
    return if business.nil?
    Rails.logger.debug "for Business #{business.name}"
    if data[:type] == 'Enrollment'
      Rails.logger 'Enrollment'
      #Create local contact
      padma_contact = PadmaContact.find(data[:contact_id],
                                        :select => [:first_name, :last_name, :status, :global_teacher_username],
                                        :account_name => business.padma_id)
      Rails.logger.debug "for padma_contact [##{data[:contact_id]}] #{padma_contact.first_name} #{padma_contact.last_name}"
      contact = Contact.find_or_create_by_padma_id(:padma_id => padma_contact.id,
                                                     :business_id => business.id,
                                                     :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
                                                     :padma_status => padma_contact.status,
                                                     :padma_teacher => padma_contact.global_teacher_username)
      Rails.logger.debug "local contact ##{contact.id} #{contact.created_at >= 1.minute.ago ? "created" : "found"}"
      # TODO: Create Membership using data from message
    elsif data[:type] == 'DropOut'
      #TODO: Close membership
    end
  end
end