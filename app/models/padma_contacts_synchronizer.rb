class PadmaContactsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    contacts = @business.contacts
    if contacts.empty?
      # Get all students
      padma_contacts = PadmaContact.search(select: [:first_name, :last_name, :status, :global_teacher_username], :where => {:updated_at =>  @business.synchronized_at, :status => "student"}, per_page: 9999, username: @business.owner.username, account_name: @business.padma_id)
    else
      # Get all contacts updated after last sync
      padma_contact_ids = contacts.map(&:padma_id).uniq
      padma_contacts = PadmaContact.search(select: [:first_name, :last_name, :status, :global_teacher_username], ids: padma_contact_ids, :where => {:updated_at =>  @business.synchronized_at}, per_page: padma_contact_ids.size, username: @business.owner.username, account_name: @business.padma_id)
    end

    padma_contacts.each do |padma_contact|
        contact = contacts.detect {|c| c.padma_id == padma_contact.id} 
        if (contact)
          # If contact existed already update it
          contact.update_attributes(
  	        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
  	        :padma_status => padma_contact.status,
  	        :padma_teacher => padma_contact.global_teacher_username)
        else
          # Otherwise create it
          @business.contacts.create(
            :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
            :padma_status => padma_contact.status,
            :padma_teacher => padma_contact.global_teacher_username)
        end
    end
    @business.update_attribute(:synchronized_at, DateTime.now)
  end
end