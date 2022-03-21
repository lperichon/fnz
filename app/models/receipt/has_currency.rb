module Receipt::HasCurrency
  extend ActiveSupport::Concern

  included do

    before_validation :set_default_currency

    validates :currency_id, presence: true

    def currency
      @currency ||= Currency.find(currency_id)
    end

    private

    def set_default_currency
      if self.currency_id.blank?
        self.currency_id = business.currency_code
      end
    end

  end
end
