class PadmaContactsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    contacts = @business.contacts
    padma_contact_ids = contacts.map(&:padma_id).uniq
    padma_contacts = PadmaContact.search(select: [:first_name, :last_name, :status, :global_teacher_username], ids: padma_contact_ids, :where => {:updated_at =>  @business.synchronized_at}, per_page: padma_contact_ids.size, username: @business.owner.username, account_name: @business.padma_id)

    padma_contacts.each do |padma_contact|
        contact = contacts.detect {|c| c.padma_id == padma_contact.id} 

        contact.update_attributes(
	        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
	        :padma_status => padma_contact.status,
	        :padma_teacher => padma_contact.global_teacher_username)
    end
    business.update_attribute(:synchronized_at, Date.today)
  end
end