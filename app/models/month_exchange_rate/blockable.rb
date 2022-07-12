module MonthExchangeRate::Blockable
  extend ActiveSupport::Concern

  included do

    validate :wont_violate_block

    # @return [Boolean]
    def blocked?
      if business.block_transactions_before && ref_date
        ref_date <= business.block_transactions_before.to_date
      end
    end

    # @return [Boolean]
    def change_allowed?(attr)
      blocked? ? attr.in?(%W()) : true
    end

    def wont_violate_block
      if blocked?
        unless changed.all? { |attr| change_allowed?(attr) }
          errors.add(:ref_date,
            I18n.t("transactions.you_blocked_all_before",
              date: business.block_transactions_before))
        end
      elsif business.block_transactions_before
        if ref_date_changed?
          if ref_date < business.block_transactions_before
            errors.add(:ref_date,
              I18n.t("transactions.you_blocked_all_before",
                date: business.block_transactions_before))
          end
        end
      end
    end


  end
end
