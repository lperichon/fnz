class MonthExchangeRate < ActiveRecord::Base

  include Shared::MonthRefDate
  include Monthly # Depends on Shared::MonthRefDate
  include Blockable

  belongs_to :business

  validates :source_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}
  validates :target_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}

  validate :different_currencies

  validates :conversion_rate, presence: true

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

end
