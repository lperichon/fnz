module Transaction::HasAutomations
  extend ActiveSupport::Concern

  included do

    before_create :assign_contact_from_description
    before_create :apply_automation_rules

    attr_accessor :skip_infer_associations
    after_save :infer_associations, unless: :skip_infer_associations

    def assign_contact_from_description
      begin
        if business && contact_id.nil?
          business.contacts.each do |c|
            if description.match(c.name.strip)
              self.contact = c
              break
            end
          end
        end
      rescue => e
        Rails.logger.warn "[automation skipped] #{e.message}"
      end
    end

    def apply_automation_rules
      return nil if business.nil?

      get_automation_rules.each do |rule|
        if rule.matches?(self)
          rule.set_values(self)
        end
      end
    end

    def get_automation_rules
      @automation_rules ||= business.transaction_rules.all
    end

    # installments automagic
    def infer_associations
      return if business_id.nil?
      if admpart_tag
        # tagged

        if !contact_id.blank? && admpart_tag.in?(Tag.system_tags_tree(business_id,"installment"))
          # with installments

          if installments.empty?
            # but no installments
            # find installments and link
            installment = Installment.for_contact(contact_id)
                                     .on_business(business_id)
                                     .on_month(report_at.nil?? transaction_at : report_at ) # fetch installment of report month first, or of transaction month
                                     .first
            if installment
              if agent_id.blank? && installment.agent_id
                update_attribute(:agent_id, installment.agent_id)
                # TODO if installment.agent_id is NULL get contact.padma_teacher
              end
              # to ensure callbacks that calculate balances, etc.
              InstallmentTransaction.create(
                installment_id: installment.id,
                transaction_id: id
              )
            elsif agent_id.blank? && contact.teacher
              # installment not found, get agent from contact
              update_attribute :agent_id, contact.teacher.id
            end
          end
        end
      elsif !installments.empty?
        # not tagged and installments linked

        ref_installment = self.installments.first

        new_attrs = {
          contact_id: ref_installment.try(:membership).try(:contact_id),
          agent_id: ref_installment.agent_id
        }

        if t = Tag.where(business_id: business_id, system_name: "installment").first
          # add tag without saving
          # when tag is added, it will update admpart_tag too
          self.association(:tags).add_to_target(t)
        end

        self.skip_infer_associations = true
        update_attributes(new_attrs)
      end
    end
  end
end
