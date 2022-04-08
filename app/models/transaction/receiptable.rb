module Transaction::Receiptable
  extend ActiveSupport::Concern

  included do

    belongs_to :receipt

    attr_accessor :receipt_on_create, :receipt_email

    def can_receipt?
      is_a?(Credit) && state != "pending"
    end

    # @return [Receipt]
    def generate_receipt
      r = business.receipts.create(
        email: receipt_email,
        contact_id: contact_id,

        description: description,
        amount_cents: amount_cents,
        currency_id: source.currency_code,
        ref_date: transaction_at,
      )
      self.update_columns(receipt_id: r.id) if r.persisted?
      r
    end

    private

    def receipt_date
      (state == "reconciled") ? reconciled_at : transaction_at
    end

  end
end
