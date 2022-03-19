class MonthExchangeRate < ActiveRecord::Base

  include Shared::MonthRefDate
  include Monthly # Depends on Shared::MonthRefDate
  include Blockable

  belongs_to :business

  validates :source_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}
  validates :target_currency_code, presence: true, inclusion: {in: SUPPORTED_CURRENCIES.map(&:iso_code)}

  validates :conversion_rate, presence: true

  def inverse_conversion_rate
    if conversion_rate
      1 / conversion_rate
    end
  end

end
