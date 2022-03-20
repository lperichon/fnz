module MonthExchangeRate::ThirdParty
  extend ActiveSupport::Concern

  included do

    def update_rate_from_3rd_party
      if (new_rate = self.class.get_rate_from_3rd_party(from_currency_id, to_currency_id, ref_date))
        update(conversion_rate: new_rate)
      end
    end

    def self.get_rate_from_3rd_party(from_cur, to_cur, ref_date)
      if Rails.env.test?
        100.0
      else
        if from_cur.present? && to_cur.present? && ref_date
          if current_month?(ref_date)
            if DolarSiClient.use_for?(from_cur) && to_cur == "ars"
              DolarSiClient.new(currency: from_cur).current
            elsif from_cur == "ars" && DolarSiClient.use_for?(to_cur)
              if (r = DolarSiClient.new(currency: to_cur).current)
                1 / r
              end
            else
              client = OpenExchangeRatesClient.new(from_cur: Currency.find(from_cur).iso_code, to_cur: Currency.find(to_cur).iso_code)
              client.latest
            end
          else
            client = OpenExchangeRatesClient.new(from_cur: Currency.find(from_cur).iso_code, to_cur: Currency.find(to_cur).iso_code)
            client.historical(ref_date.end_of_month < Time.zone.today ? ref_date.end_of_month : ref_date) # para meses pasados usar el último día del mes.
          end
        end
      end
    end
  end

end
