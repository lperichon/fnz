module Receipt::HasCurrency
  extend ActiveSupport::Concern

  included do

    validates :currency_id, presence: true

    def currency
      @currency ||= Currency.find(currency_id)
    end

  end
end
