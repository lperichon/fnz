module Account::HasCurrency
  extend ActiveSupport::Concern

  included do

    validates :currency, presence: true
    after_save :update_calculations

    def currency=(currency_code)
      self[:currency] = currency_code
    end

    def currency
      ret = Currency.find(self[:currency])
      if ret.nil? && business
        ret = Currency.find(business.currency_code)
      end
      if ret.nil?
        ret = Currency.find(:usd)
      end
      ret
    end

    def currency_code=(currency_code)
      self[:currency] = currency_code
    end

    def currency_code
      self[:currency]
    end

    def update_calculations
      if currency_changed?
        business.month_exchange_rates.for_currency(currency_was).each &:update_calculations
        business.month_exchange_rates.for_currency(currency_code).each &:update_calculations
      end
    end

  end
end
