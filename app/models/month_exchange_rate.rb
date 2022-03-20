class MonthExchangeRate < ActiveRecord::Base

  include Shared::MonthRefDate
  include Monthly # Depends on Shared::MonthRefDate
  include Blockable
  include InverseConversion

  belongs_to :business

  before_validation :upcase_currency_codes

  validates :source_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}
  validates :target_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}

  validate :dont_duplicate
  validate :different_currencies

  validates :conversion_rate, presence: true

  after_save :update_calculations

  def self.conversion_rate(from_cur, to_cur, ref_date)
    if from_cur.upcase == to_cur.upcase
      1.0
    elsif (ex_rate = get_for_month(from_cur, to_cur, ref_date))
      ex_rate.conversion_rate
    elsif (ex_rate = get_for_month(to_cur, from_cur, ref_date))
      ex_rate.inverse_conversion_rate
    end
  end

  private

  def different_currencies
    if source_currency_code == target_currency_code
      errors.add(:source_currency_code, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
      errors.add(:target_currency_code, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
    end
  end

  def dont_duplicate
    if source_currency_code && target_currency_code
      scope = business.month_exchange_rates.where(ref_date: ref_date)
      if persisted?
        scope = scope.where.not(id: id)
      end
      if scope.where(
                   source_currency_code: source_currency_code.upcase,
                   target_currency_code: target_currency_code.upcase,
                   )
                 .exists? || scope.where(
        source_currency_code: target_currency_code.upcase,
        target_currency_code: source_currency_code.upcase,
        ).exists?
        errors.add(:source_currency_code, "duplicate")
        errors.add(:target_currency_code, "duplicate")
      end
    end
  end

  def upcase_currency_codes
    if source_currency_code.upcase != source_currency_code
      self.source_currency_code = source_currency_code.upcase
    end
    if target_currency_code.upcase != target_currency_code
      self.target_currency_code = target_currency_code.upcase
    end
  end

  def update_calculations
    if conversion_rate_changed?
      business.accounts.where(currency: [source_currency_code, target_currency_code]).each do |account|
        try_with_transfers = true
        # Recalcular reportes. 1 x tag
        Transaction.to_report_on_month(ref_date)
          .where("source_id == :account_id OR target_id = :account_id", account_id: account.id)
          .select("DISTINCT ON (admpart_tag_id) * ") # esto hace que me devuelva 1 x tag. @see https://stackoverflow.com/questions/3800551/select-first-row-in-each-group-by-group , TODO confirmar
          .each do |transaction|
          transaction.delay.update_balances
          try_with_transfers = false
        end

        if try_with_transfers
          # Todavía No se disparó actualización en esta account
          # Recalcular balances de cuentas. Solo transfers, 1 x account suficiente.
          # El conversion rate solo afecta el balance de la target, no de la source
          Transfer.where("transaction_at >= ? AND transaction_at <= ?", ref_date.beginning_of_month, ref_date.end_of_month)
                  .where(target_id: account.id)
                  .first
                  .delay.update_balances
        end
      end
    end
  end

end
