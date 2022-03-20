module MonthExchangeRate::ThirdParty
  extend ActiveSupport::Concern

  included do
    def self.get_rate_from_3rd_party(from_cur, to_cur, ref_date)
      if Rails.env.test?
        100.0
      else
        if from_cur.present? && to_cur.present? && ref_date

          client = OpenExchangeRatesClient.new(from_cur: Currency.find(from_cur).iso_code, to_cur: Currency.find(to_cur).iso_code)
          client.historical(ref_date)
        end
      end
    end
  end

end
