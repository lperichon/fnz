class Contact
  module GetsByPadmaId
    extend ActiveSupport::Concern

    included do
      # finds contact by padma_id
      # if it doesnt exist it creates
      # BUSINESS should be specified on scope, padma_id is not unique
      def self.get_by_padma_id(padma_id)
        c = find_by_padma_id(padma_id)
        if c.nil?
          if (b = Business.get_from_scope(self))
            padma_contact = CrmLegacyContact.find(padma_id,
              select: [:id, :full_name, :email, :local_status, :local_teacher],
              account_name: b.padma_id
            )
            if padma_contact
              if (c = get_by_crm_padma_id(padma_contact))
              else
                c = b.contacts.create(
                  name: padma_name(padma_contact).strip,
                  email: padma_contact.email,
                  padma_status: padma_contact.local_status,
                  padma_teacher: padma_contact.local_teacher,
                  padma_id: padma_contact.id)
              end
            end
          end
        end
        c
      end

      def self.padma_name(pc)
        if pc.friendly_name.present?
          "#{pc.friendly_name} #{pc.last_name}"
        else
          "#{pc.first_name} #{pc.last_name}"
        end
      end

      private

      # busco si tengo contacto con el crm_padma_id de este padma_id
      # si encuentro le actualizo el padma_id
      def self.get_by_crm_padma_id(padma_contact)
        ret = nil
        if (ret = find_by_padma_id padma_contact.crm_padma_id)
          ret.update_column :padma_id, padma_contact.id
        end
        ret
      end
    end
  end
end
