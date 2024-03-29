# El modelo se reproduce todos los meses, para todos los meses debe tener algún valor
module MonthExchangeRate::MonthlyHistory
  extend ActiveSupport::Concern

  included do

    def previous_month
      business.month_exchange_rates.on_month(ref_date-1.month).first
    end

    def next_month
      business.month_exchange_rates.on_month(ref_date+1.month).first
    end

    # * Si ya hay un ExchangeRate para el mes retorna ese.
    # * Si no busca el rate en un 3rd Party y lo guarda
    # * Si no clona el más cercano en un rango de 3 meses.
    # * Si no trata de generar a partir de un Transfer
    #
    # @return [MonthExchangeRate]
    def self.get_for_month(from_cur, to_cur, rd)
      rd = rd.to_date unless rd.is_a?(Date)
      cur_scope = where(from_currency_id: from_cur.downcase, to_currency_id: to_cur.downcase)
      unless (ret = cur_scope.on_month(rd).first)
        if (rate = get_rate_from_3rd_party(from_cur, to_cur, rd))
          ret = self.create(
            from_currency_id: from_cur,
            to_currency_id: to_cur,
            ref_date: rd,
            conversion_rate: rate
          )
        else
          clone_ref = cur_scope.find_closest_to(rd)
          if clone_ref
            ret = MonthExchangeRate.create(clone_ref.attributes_for_clone.merge({ref_date: rd}))
          else
            if (business = get_business_from_scope(self)) && (ref_transfer = get_ref_transfer(from_cur, to_cur, business))
              ret = self.create(
                from_currency_id: from_cur,
                to_currency_id: to_cur,
                ref_date: rd,
                conversion_rate: (ref_transfer.source.currency_code == from_cur)? ref_transfer.conversion_rate : 1 / ref_transfer.conversion_rate
              )
            end
          end
        end
      end
      ret
    end

    def attributes_for_clone
      attributes.reject{|a| a.in?(%W(id ref_date created_at updated_at))}
    end

    private

    def self.get_ref_transfer(from_cur, to_cur, business)
      from_cur_account_ids = business.accounts.where(currency: from_cur).pluck(:id)
      to_cur_account_ids = business.accounts.where(currency: to_cur).pluck(:id)
      Transfer.where(source_id: from_cur_account_ids, target_id: to_cur_account_ids)
              .order(:transaction_at).last # TODO use in ref_date
    end

    def self.get_business_from_scope(scope)
      Business.get_from_scope(scope)
    end

  end
end
