module Business::HasCurrency
  extend ActiveSupport::Concern

  included do

    validates :currency_code, presence: true
    after_save :update_calculations

    def currency_symbol
      if currency_code
        Currency.find(currency_code).try(:symbol)
      else
        Currency.find("usd").try(:symbol)
      end
    end

    def update_calculations
      if currency_code_changed?
        month_exchange_rates.each &:update_calculations
      end
    end

  end
end
