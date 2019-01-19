class Admpart < ActiveRecord::Base
  
  belongs_to :business

  has_many :admpart_tags

  attr_accessor :ref_date,
                :force_refresh


  VALID_SECTIONS = %W(income expense ignore)

  # total_income - total_expense
  def profit
    section_total("income") - section_total("expense")
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
    cache_key = [self,"total_for_tag",tag]
    @total = Rails.cache.read(cache_key)
    if @total && !force_refresh
      @total
    else
      @total = 0
      # TODO consider currencies
      # TODO consider state of transaction
      @total += tag.transactions.debits.to_report_on_month(ref_date).sum(:amount)
      @total -= tag.transactions.credits.to_report_on_month(ref_date).sum(:amount)
      tag.descendants.each do |d|
        @total += d.transactions.debits.to_report_on_month(ref_date).sum(:amount)
        @total -= d.transactions.credits.to_report_on_month(ref_date).sum(:amount)
      end
      Rails.cache.write(cache_key, @total, expires_in: CACHE_DURATION)
      @total
    end
  end

end
