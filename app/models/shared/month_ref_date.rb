# Uso el primer día del mes para identificar el mes
#
# expects base_class to have ref_date accessor
module Shared::MonthRefDate
  extend ActiveSupport::Concern

  included do

    before_validation :force_ref_date_to_first_day_of_month

    validates :ref_date, presence: true
    validate :ref_date_first_day_of_month

    scope :on_month, ->(rd) { where(ref_date: cast_date(rd)) }

    def self.cast_date(date)
      date.to_date.beginning_of_month
    end

    private

    def force_ref_date_to_first_day_of_month
      if ref_date && ref_date.day != 1
        self.ref_date= self.class.cast_date(ref_date)
      end
    end


    def ref_date_first_day_of_month
      if ref_date && ref_date.day != 1
        errors.add(:ref_date, "must be first day of month")
      end
    end

  end

end
