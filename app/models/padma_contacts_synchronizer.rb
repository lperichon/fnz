class PadmaContactsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    contacts = @business.contacts
    if contacts.empty? || @business.synchronized_at.nil?
      # Get all students and former students
      padma_contacts = CrmLegacyContact.search(select: [:first_name, :last_name, :local_status, :local_teacher], :where => {:updated_at =>  @business.synchronized_at, :local_status => ["student", "former_student"]}, per_page: 9999, username: @business.owner.username, account_name: @business.padma_id)
    else
      # Get all contacts updated after last sync
      padma_contact_ids = contacts.map(&:padma_id).uniq
      padma_contacts = CrmLegacyContact.search(select: [:first_name, :last_name, :local_status, :local_teacher], ids: padma_contact_ids, :where => {:updated_at =>  @business.synchronized_at}, per_page: padma_contact_ids.size, username: @business.owner.username, account_name: @business.padma_id)
    end

    padma_contacts.each do |padma_contact|
        if (contact = contacts.detect {|c| c.padma_id == padma_contact.id})
          # If contact existed already update it
          contact.update_attributes(
  	        :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
  	        :padma_status => padma_contact.local_status,
  	        :padma_teacher => padma_contact.local_teacher)
        else
          # Otherwise create it
          @business.contacts.create(
            :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip,
            :padma_status => padma_contact.local_status,
            :padma_teacher => padma_contact.local_teacher,
            :padma_id => padma_contact.id)
        end
    end
    @business.update_attribute(:synchronized_at, DateTime.now)
  end
end
