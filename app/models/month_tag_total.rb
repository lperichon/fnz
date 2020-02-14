##
#
# Total on month using transactions report_on date
#
class MonthTagTotal < ActiveRecord::Base
  attr_accessible :ref_date, :tag_id

  belongs_to :tag

  before_validation :force_ref_date_to_first_day_of_month
  validates :ref_date, presence: true

  before_save :calculate_total_amount

  def calculate_total_amount
    self.total_amount = tag.tree_transactions
         .to_report_on_month(ref_date)
         .sum("CASE WHEN transactions.type='Credit' THEN transactions.amount WHEN transactions.type='Debit' THEN -1 * transactions.amount ELSE 0 END").to_f # using CASE casts to string ¿?
  end

  def self.get_for(tag, ref_date)
    ret = self.where(tag_id: tag.id, ref_date: cast_date(ref_date)).first
    if ret.nil?
      create!(
        ref_date: cast_date(ref_date),
        tag_id: tag.id
      )
    else
      ret
    end
  end

  def self.cast_date(date)
    date.beginning_of_month
  end

  private

  def force_ref_date_to_first_day_of_month
    if ref_date && ref_date.day != 1
      self.ref_date= MonthTagTotal.cast_date(ref_date)
    end
  end
end
