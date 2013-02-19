class PadmaContactsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    page = 1
    more_contacts = true
    while(more_contacts)
      padma_contacts = PadmaContact.search(:where => {:updated_at =>  business.synchronized_at},
                        :account_name => business.padma_id,
                        :per_page => 100,
                        :page => page).each do |padma_contact|
        contact = Contact.find_or_create_by_padma_id(:padma_id => padma_contact.id,
                                                   :business_id => business.id,
                                                   :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
                                                   :padma_status => padma_contact.status,
                                                   :padma_teacher => padma_contact.global_teacher_username)
        unless contact.created_at && contact.created_at > 10.seconds.ago
          contact.update_attributes(
            :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
            :padma_status => padma_contact.status,
            :padma_teacher => padma_contact.global_teacher_username)
        end
      end
      more_contacts = !padma_contacts.empty?
      page = page + 1
    end
    business.update_attribute(:synchronized_at, Date.today)
  end
end