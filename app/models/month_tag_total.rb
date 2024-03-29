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

  def transactions
    tag.tree_transactions.to_report_on_month(ref_date)
  end

  def calculate_total_amount
    self.total_amount_cents = transactions.sum_w_rates(tag.business, ref_date)
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
