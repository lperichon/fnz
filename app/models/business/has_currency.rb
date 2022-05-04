module Business::HasCurrency
  extend ActiveSupport::Concern

  included do

    before_validation :set_default_currency
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

    private

    def set_default_currency
      if currency_code.nil?
        if (padma_account = padma)
          self.currency_code = case padma_account.country
            when "Brazil"
              "brl"
            when "Argentina"
              "ars"
            else
              "usd"
          end
        else
          self.currency_code = "usd"
        end
      end

    end

  end
end
