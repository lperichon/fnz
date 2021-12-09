class FetchCrmContactJob

  # @param attributes
  # @option id REQUIRED padma_id del contacto
  # @option business_padma_id OPTIONAL account_name de la escuela
  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    ret = false
    if business
      ret = resync_for_business(business)
    else
      padma_contact.local_statuses.each do |ls|
        if (pc = get_padma_contact(ls["account_name"]))
          if (business = Business.find_by_padma_id ls["account_name"])
            ret = resync_for_business(business, pc)
          end
        end
      end
    end
    ret
  end

  private

  def resync_for_business(business, pc = nil)
    pc = padma_contact if pc.nil?
    if (contact = business.contacts.find_by_padma_id(pc.id))
      # If contact existed already update it
      contact.update_attributes(
        :name => "#{pc.first_name} #{pc.last_name}".strip,
        :padma_status => pc.local_status,
        :padma_teacher => pc.local_teacher)
    else
      contact = business.contacts.get_by_padma_id(pc.id)
    end
  end

  def get_padma_contact(account_name)
    CrmLegacyContact.find @attributes[:id], account_name: account_name
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
