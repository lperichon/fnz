module Business::HasContacts
  extend ActiveSupport::Concern

  included do

    has_many :contacts

    # encola actualización de alumnos y ex-alumnos
    def queue_syncs_from_crm
      per_page = 500
      page = 1
      loop do
        pcs = CrmLegacyContact.paginate(
          account_name: padma_id,
          page: page,
          per_page: per_page,
          where: {local_status: %W(student former_student)}
        )
        break if pcs.blank?
        pcs.each do |pc|
          Delayed::Job.enqueue FetchCrmContactJob.new(id: pc.id, business_padma_id: padma_id)
        end
        page += 1
      end
    end
  end
end
