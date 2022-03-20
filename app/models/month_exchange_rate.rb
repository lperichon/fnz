class MonthExchangeRate < ActiveRecord::Base

  include Shared::MonthRefDate
  include Monthly # Depends on Shared::MonthRefDate
  include Blockable
  include InverseConversion

  belongs_to :business

  before_validation :downcase_currency_codes

  validates :from_currency_id, presence: true, inclusion: {in: SUPPORTED_CURRENCIES}
  validates :to_currency_id, presence: true, inclusion: {in: SUPPORTED_CURRENCIES}

  validate :dont_duplicate
  validate :different_currencies

  validates :conversion_rate, presence: true

  after_save :update_calculations

  def self.conversion_rate(from_cur, to_cur, ref_date)
    if from_cur.downcase == to_cur.downcase
      1.0
    elsif (ex_rate = get_for_month(from_cur, to_cur, ref_date))
      ex_rate.conversion_rate
    elsif (ex_rate = get_for_month(to_cur, from_cur, ref_date))
      ex_rate.inverse_conversion_rate
    end
  end

  def update_calculations
    if conversion_rate_changed?
      business.accounts.where(currency: [from_currency_id, to_currency_id]).each do |account|
        try_with_transfers = true
        # Recalcular reportes. 1 x tag
        Transaction.to_report_on_month(ref_date)
                   .where("source_id = :account_id OR target_id = :account_id", account_id: account.id)
                   .select("DISTINCT ON (admpart_tag_id) * ") # esto hace que me devuelva 1 x tag. @see https://stackoverflow.com/questions/3800551/select-first-row-in-each-group-by-group , TODO confirmar
                   .each do |transaction|
          transaction.delay.update_balances
          try_with_transfers = false
        end

        if try_with_transfers
          # Todavía No se disparó actualización en esta account
          # Recalcular balances de cuentas. Solo transfers, 1 x account suficiente.
          # El conversion rate solo afecta el balance de la target, no de la source
          if (transfer = Transfer.where("transaction_at >= ? AND transaction_at <= ?", ref_date.beginning_of_month, ref_date.end_of_month)
                                 .where(target_id: account.id)
                                 .first)
            transfer.delay.update_balances
          end
        end
      end
    end
  end

  private

  def different_currencies
    if from_currency_id == to_currency_id
      errors.add(:from_currency_id, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
      errors.add(:to_currency_id, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
    end
  end

  def dont_duplicate
    if from_currency_id && to_currency_id
      scope = business.month_exchange_rates.where(ref_date: ref_date)
      if persisted?
        scope = scope.where.not(id: id)
      end
      if scope.where(
                   from_currency_id: from_currency_id.downcase,
                   to_currency_id: to_currency_id.downcase,
                   )
                 .exists? || scope.where(
        from_currency_id: to_currency_id.downcase,
        to_currency_id: from_currency_id.downcase,
        ).exists?
        errors.add(:from_currency_id, "duplicate")
        errors.add(:to_currency_id, "duplicate")
      end
    end
  end

  def downcase_currency_codes
    if from_currency_id.downcase != from_currency_id
      self.from_currency_id = from_currency_id.downcase
    end
    if to_currency_id.downcase != to_currency_id
      self.to_currency_id = to_currency_id.downcase
    end
  end

end
