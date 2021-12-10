module Transaction::HasAutomations
  extend ActiveSupport::Concern

  included do

    before_create :assign_contact_from_description
    before_create :apply_automation_rules

    def assign_contact_from_description
      if business && contact_id.nil?
        business.contacts.each do |c|
          if description.match(c.name.strip)
            self.contact = c
            break
          end
        end
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

  end
end
