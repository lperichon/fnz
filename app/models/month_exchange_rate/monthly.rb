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
        else
          business = Business.find(get_business_from_scope(self)) # will fail if no business in scope
          if (ref_transfer = transfer_between_currencies(from_cur, to_cur, business))
            ret = self.create(
              source_currency_code: from_cur,
              target_currency_code: to_cur,
              ref_date: rd,
              conversion_rate: (ref_transfer.source.currency == from_cur)? ref_transfer.conversion_rate : 1 / ref_transfer.conversion_rate
            )
          end
        end
      end
      ret
    end

    def attributes_for_clone
      attributes.reject{|a| a.in?(%W(id ref_date created_at updated_at))}
    end

    private

    def transfer_between_currencies(from_cur, to_cur, business)
      from_cur_account_ids = business.accounts.where(currency: from_cur).pluck(:id)
      to_cur_account_ids = business.accounts.where(currency: to_cur).pluck(:id)
      Transfer.where(source_id: from_cur_account_ids, target_id: to_cur_account_ids)
              .order(:transacted_at).last || Transfer.where(source_id: to_cur_account_ids, target_id: from_cur_account_ids)
                                                     .order(:transacted_at).last
    end

    def self.get_business_from_scope(scope)
      scope = scope.where(nil)
      res = scope.to_sql.match(/business_id\" \= (\d+)/)
      (res)? res[1].to_i : nil
    end

  end
end
