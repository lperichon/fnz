class PadmaContactsSynchronizer
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def sync
    PadmaContact.search(:where => {:updated_at =>  business.synchronized_at},
                        :account_name => business.padma_id).each do |padma_contact|
      contact = Contact.find_or_create_by_padma_id(:padma_id => padma_contact.id,
                                                   :business_id => business.id,
                                                   :name => "#{padma_contact.first_name} #{padma_contact.last_name}".strip)
      #TODO: update cached values on existing contacts
      #unless contact.created_at < 10.seconds.ago
      #  contact.update_attributes
      #end
    end

    business.update_attribute(:synchronized_at, Date.today)
  end
end