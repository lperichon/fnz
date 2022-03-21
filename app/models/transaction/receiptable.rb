module Transaction::Receiptable
  extend ActiveSupport::Concern

  included do

    has_one :receipt

    attr_accessor :receipt_on_create, :receipt_email

    def can_receipt?
      is_a?(Credit) && state != "pending"
    end

    # @return [Receipt]
    def generate_receipt
      business.receipts.create(
        email: receipt_email,
        contact_id: contact_id,

        description: description,
        amount_cents: amount_cents,
        currency_id: source.currency_code,
        ref_date: transaction_at,

        transaction_id: id
      )
    end

  end
end
