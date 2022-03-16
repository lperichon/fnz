module Account::HasCurrency
  extend ActiveSupport::Concern

  included do

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

  end
end
