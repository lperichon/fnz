class Admpart < ActiveRecord::Base
  
  belongs_to :business

  has_many :admpart_tags

  validates :owners_percentage,
            allow_blank: true,
            numericality: {
              only_integer: true,
              greather_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  validates :director_from_profit_percentage,
            allow_blank: true,
            numericality: {
              only_integer: true,
              greather_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  attr_accessor :ref_date,
                :force_refresh


  VALID_SECTIONS = %W(income expense ignore director_expenses owners_expenses)

  before_save :set_defaults

  def teams_amount
    total_before_owner + owners_pre_expenses_amount # resto el pre-expenses, si no estaria restando 2 veces.
  end
  
  def teams_percentage
    100 - owners_percentage
  end

  def owners_pre_expenses_amount
    owners_percentage * total_before_owner / 100
  end
  
  def owners_final_amount
    owners_pre_expenses_amount + section_total("owners_expenses")
  end

  def total_before_owner
    profit - director_from_profit_pre_expenses_amount # resto el pre-expenses, si no estaria restando 2 veces.
  end

  # winnings for director directly from profit before distribution
  def director_from_profit_pre_expenses_amount
    if director_from_profit_percentage
      ret = director_from_profit_percentage * profit / 100
      (ret >= 0)? ret : 0 # can be < 0
    else
      0
    end
  end

  def director_from_profit_final_amount
    director_from_profit_pre_expenses_amount + section_total("director_expenses")
  end

  # total_income + total_expense
  def profit
    section_total("income") + section_total("expense")
  end

  def section_total(section)
    root_tags_for_section(section).sum{|t| total_for_tag(t) }
  end

  def root_tags_for_section(section)
    business.tags.roots.where(admpart_section: section)
  end

  def wout_section_root_tags
    business.tags.roots.where("admpart_section is null or admpart_section not in (?)", VALID_SECTIONS)
  end

  CACHE_DURATION = 5.minutes
  def total_for_tag(tag)
    cache_key = [self,ref_date,"total_for_tag",tag]
    @total = Rails.cache.read(cache_key)
    if @total && !force_refresh
      @total
    else
      @total = 0
      # TODO consider currencies
      # TODO consider state of transaction
      @total += tag.transactions.credits.to_report_on_month(ref_date).sum(:amount)
      @total -= tag.transactions.debits.to_report_on_month(ref_date).sum(:amount)
      tag.descendants.each do |d|
        @total += d.transactions.credits.to_report_on_month(ref_date).sum(:amount)
        @total -= d.transactions.debits.to_report_on_month(ref_date).sum(:amount)
      end
      Rails.cache.write(cache_key, @total, expires_in: CACHE_DURATION)
      @total
    end
  end

  private

  def set_defaults
    self.owners_percentage = 50 if self.owners_percentage.nil?
  end

end
