module Transaction::Blockable
  extend ActiveSupport::Concern

  included do

    validate :wont_violate_block

    def blocked?
      if business.block_transactions_before && report_at
        report_at <= business.block_transactions_before
      end
    end

    def wont_violate_block
      if business.block_transactions_before
        if report_at_changed?
          if report_at < business.block_transactions_before
            errors.add(:report_at,
              I18n.t("transactions.you_blocked_all_before",
                date: business.block_transactions_before))
          end
        end
      end
    end

    private

    def change_allowed?(attr)
      attr.in?(%W(state reconciled_at))
    end

  end
end
