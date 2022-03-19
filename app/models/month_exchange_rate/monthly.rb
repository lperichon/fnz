# El modelo se reproduce todos los meses, para todos los meses debe tener algún valor
module MonthExchangeRate::Monthly
  extend ActiveSupport::Concern

  included do

    def previous_month
      business.month_exchange_rates.on_month(ref_date-1.month).first
    end

    def next_month
      business.month_exchange_rates.on_month(ref_date+1.month).first
    end

    # busca y si no encuentra crea
    # @return [MonthExchangeRate]
    def self.get_for_month(from_cur, to_cur, rd)
      cur_scope = where(source_currency_code: from_cur, target_currency_code: to_cur)
      unless (ret = cur_scope.on_month(rd).first)
        clone_ref = cur_scope.find_closest_to(rd)
        if clone_ref
          ret = MonthExchangeRate.create(clone_ref.attributes_for_clone.merge({ref_date: rd}))
        end
      end
      ret
    end

    def attributes_for_clone
      attributes.reject{|a| a.in?(%W(id ref_date created_at updated_at))}
    end

  end
end
