##
#
# Total on month using transactions report_on date
#
class MonthTagTotal < ActiveRecord::Base
  #attr_accessible :ref_date, :tag_id

  include Shared::MonthRefDate
  include Shared::HasCents
  has_cents_for :total_amount

  belongs_to :tag

  before_validation :set_default_currency

  before_save :calculate_total_amount

  validates :ref_date, uniqueness: { scope: :tag_id }

  def refresh
    save # triggers calculation but better readibility and refactorable
  end

  def calculate_total_amount
    totals_by_currency = tag.tree_transactions
     .to_report_on_month(ref_date)
     .joins(:source)
     .group("accounts.currency")
     .sum("CASE WHEN transactions.type='Credit' THEN transactions.amount_cents WHEN transactions.type='Debit' THEN -1 * transactions.amount_cents ELSE 0 END")
    total = totals_by_currency.sum do |currency, total|
      if (rate = tag.business.month_exchange_rates.conversion_rate(currency, tag.business.currency_code, ref_date))
        total * rate
      else
        raise "MonthExchangeRate not found"
      end
    end
    self.total_amount_cents = total
  end

  def self.get_for(tag, ref_date)
    ret = self.where(tag_id: tag.id, ref_date: cast_date(ref_date)).first
    if ret.nil?
      create(
        ref_date: cast_date(ref_date),
        tag_id: tag.id
      )
    else
      ret
    end
  end

  private

  def set_default_currency
    self.currency = tag.business.currency_code
  end

end
