# Blockea transacciones en funcion de su *report_at*
module Transaction::Blockable
  extend ActiveSupport::Concern

  included do

    validate :wont_violate_block

    # @return [Boolean]
    def blocked?
      if business.block_transactions_before && report_at
        report_at <= business.block_transactions_before
      end
    end

    # @return [Boolean]
    def change_allowed?(attr)
      blocked? ? attr.in?(%W(state reconciled_at)) : true
    end

    def wont_violate_block
      if blocked?
        unless changed.all? { |attr| change_allowed?(attr) }
          errors.add(:report_at,
            I18n.t("transactions.you_blocked_all_before",
              date: business.block_transactions_before))
        end
      elsif business.block_transactions_before
        if report_at_changed?
          if report_at < business.block_transactions_before
            errors.add(:report_at,
              I18n.t("transactions.you_blocked_all_before",
                date: business.block_transactions_before))
          end
        end
      end
    end


  end
end
