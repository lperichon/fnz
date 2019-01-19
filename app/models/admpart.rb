class Admpart < ActiveRecord::Base
  
  attr_accessible :director_from_profit_percentage, :owners_percentage, :dir_from_owners_aft_expses_percentage

  belongs_to :business

  [:owners_percentage, :director_from_profit_percentage, :dir_from_owners_aft_expses_percentage].each do |per|
    validates per,
              allow_blank: true,
              numericality: {
                only_integer: true,
                greather_than_or_equal_to: 0,
                less_than_or_equal_to: 100
              }
  end

  attr_accessor :ref_date,
                :force_refresh


  VALID_SECTIONS = %W(income expense ignore director_expenses owners_expenses teams_expenses)

  before_save :set_defaults

  # total_income + total_expense
  def profit
    section_total("income") + section_total("expense")
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

  def total_before_owner
    profit - director_from_profit_pre_expenses_amount # resto el pre-expenses, si no estaria restando 2 veces.
  end

  def owners_pre_expenses_amount
    owners_percentage * total_before_owner / 100
  end
  
  def owners_aft_expenses_amount
    owners_pre_expenses_amount + section_total("owners_expenses")
  end

  def director_from_owners_amount
    if dir_from_owners_aft_expses_percentage
      ret = dir_from_owners_aft_expses_percentage * owners_aft_expenses_amount / 100
      (ret >= 0)? ret : 0 # can be < 0
    else
      0
    end
  end

  def owners_final_amount
    owners_aft_expenses_amount - director_from_owners_amount
  end

  def teams_percentage
    100 - owners_percentage
  end

  def teams_pre_expenses_amount
    total_before_owner + owners_pre_expenses_amount # resto el pre-expenses, si no estaria restando 2 veces.
  end

  def teams_final_amount
    teams_pre_expenses_amount + section_total("teams_expenses")
  end

  def team_members
    business.agents
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

  ###
  #
  # hash of format:
  # {
  #   contact_padma_id => {
  #     total => 3,
  #     teacher_1 => '0.2',
  #     teacher_2 => '0.8'
  #   }
  #   ...
  # }
  #
  # teacher_id is username with . changed for _
  #
  def fetch_attendance_report
    cache_key = [self,ref_date,"attendance_report"]
    report = Rails.cache.read(cache_key)
    if report && !force_refresh
      report
    else
      url = ENV['attendance_url'] || CONFIG['attendance-url']
      key = ENV['attendance_key'] || CONFIG['attendance_key']

      query = {
        app_key: key,
        stats: {
          start_on: ref_date.beginning_of_month,
          end_on: ref_date.end_of_month
        },
        account_name: business.padma_id,
        include_former_students: 1,
        include_cultural_activities: 1
      }

      response = HTTParty.get("#{url}/api/v0/stats", query: query)
      report = if response.code == 200
        response.parsed_response
      else
        # attendance-ws error
        nil
      end
      Rails.cache.write(cache_key, report, expires_in: 1.hour)
      report
    end
  end

  private

  def set_defaults
    self.owners_percentage = 50 if self.owners_percentage.nil?
  end

end
