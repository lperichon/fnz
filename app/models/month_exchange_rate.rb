class MonthExchangeRate < ActiveRecord::Base

  include Shared::MonthRefDate
  include Monthly # Depends on Shared::MonthRefDate
  include Blockable

  belongs_to :business

  before_validation :upcase_currency_codes

  validates :source_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}
  validates :target_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}

  validate :different_currencies

  validates :conversion_rate, presence: true

  def self.conversion_rate(from_cur, to_cur, ref_date)
    if from_cur.upcase == to_cur.upcase
      1.0
    elsif (ex_rate = get_for_month(from_cur, to_cur, ref_date))
      ex_rate.conversion_rate
    elsif (ex_rate = get_for_month(to_cur, from_cur, ref_date))
      ex_rate.inverse_conversion_rate
    end
  end

  def inverse_conversion_rate
    if conversion_rate
      1 / conversion_rate
    end
  end

  private

  def different_currencies
    if source_currency_code == target_currency_code
      errors.add(:source_currency_code, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
      errors.add(:target_currency_code, I18n.t("month_exchange_rate.errors.currencies_must_be_different"))
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

end
