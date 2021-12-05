class FetchCrmContactJob

  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    ret = false
    if business
      ret = resync_for_business(business)
    else
      padma_contact.local_statuses.each do |ls|
        if (business = Business.find_by_padma_id ls["account_name"])
          ret = resync_for_business(business)
        end
      end
    end
    ret
  end

  private

  def resync_for_business(business)
    if (contact = business.contact.find_by_padma_id(padma_contact.id))
      # If contact existed already update it
      contact.update_attributes(
        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
        :padma_status => padma_contact.local_status,
        :padma_teacher => padma_contact.local_teacher)
    else
      contact = business.contacts.get_by_padma_id(padma_contact.id)
    end
  end

  def padma_contact
    @padma_contact ||= CrmLegacyContact.find @attributes[:id],
      account_name: @attributes[:business_padma_id],
      select: [:local_statuses]
  end

  def business
    if @attributes[:business_padma_id]
      @business ||= Business.find_by_padma_id @attributes[:business_padma_id]
    end
  end

end
