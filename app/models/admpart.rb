class Admpart < ActiveRecord::Base
  
  attr_accessible :director_from_profit_percentage,         # % del lucro para director 
                  :owners_percentage,                       # % para inversores
                  :dir_from_owners_aft_expses_percentage,   # % de inversores para director
                  :agent_sale_percentage,                   # % de la venta para instructor
                  :agent_enrollment_income_percentage,      # % de recaudación x matrículas para instructor
                  :agent_enrollment_quantity_fixed_amount   # valor fijo x matricula para instructor
  

  belongs_to :business

  [:owners_percentage,
   :director_from_profit_percentage,
   :dir_from_owners_aft_expses_percentage,
   :agent_sale_percentage,
   :agent_enrollment_income_percentage
  ].each do |per|
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
  def total_for_tag(tag,agent_id=nil,options={})
    cache_key = [id,ref_date,"total_for_tag",tag,options.to_param]
    unless agent_id.nil?
      cache_key << "agent:#{agent_id}"
    end
    contact_id = options[:contact_id]

    @total = Rails.cache.read(cache_key)
    if @total && !force_refresh
      @total
    else
      @total = 0
      # TODO consider currencies
      # TODO consider state of transaction
      
      scope = tag.transactions.to_report_on_month(ref_date)
      unless agent_id.nil?
        if agent_id == ""
          scope = scope.where("agent_id is null")
        else
          scope = scope.where(agent_id: agent_id) 
        end
      end
      unless contact_id.nil?
        if contact_id == ""
          scope = scope.where("contact_id is null")
        else
          scope = scope.where(contact_id: contact_id) 
        end
      end

      @total += scope.credits.sum(:amount)
      @total -= scope.debits.sum(:amount)

      tag.descendants.each do |d|
        s = d.transactions.to_report_on_month(ref_date)
        unless agent_id.nil?
          if agent_id == ""
            s= s.where("agent_id is null")
          else
            s= s.where(agent_id: agent_id) 
          end
        end
        unless contact_id.nil?
          if contact_id == ""
            s= s.where("contact_id is null")
          else
            s= s.where(contact_id: contact_id) 
          end
        end

        @total += s.credits.sum(:amount)
        @total -= s.debits.sum(:amount)
      end

      if agent_id.nil? && !options[:ignore_discounts]
        case tag.system_name
        when "sale" 
          @total -= sales_total_discount
        when "enrollment"
          @total -= enrollments_total_discount
        end
      end

      Rails.cache.write(cache_key, @total, expires_in: CACHE_DURATION)
      @total
    end
  end

  ###
  #
  # hash of format:
  # {
  #   contact_id => {
  #     name => "Fulano de tal",
  #     total => 3,
  #     teacher_1 => '0.2',
  #     teacher_2 => '0.8'
  #   }
  #   ...
  # }
  #
  # teacher_id is username with . changed for _
  #
  def attendance_report
    if @attendance_report
      @attendance_report
    else
      cache_key = [self,ref_date,"attendance_report"]
      report = Rails.cache.read(cache_key)
      if report && !force_refresh
        report
      else
        url = ENV['attendance_url'] || CONFIG['attendance-url']
        key = ENV['attendance_key'] || CONFIG['attendance_key']

        response = HTTParty.get("#{url}/api/v0/stats", query: attendance_report_query.merge({
          app_key: key,
          account_name: business.padma_id
        }))
        report = if response.code == 200
          response.parsed_response
        else
          # attendance-ws error
          nil
        end
        Rails.cache.write(cache_key, report, expires_in: 1.hour)
        @attendance_report = report
      end
    end
  rescue Errno::ECONNREFUSED => e
    nil
  end

  def contacts_in_attendance_report
    @contacts_in_attendance_report ||= business.contacts.where(padma_id: attendance_report.keys)
  end

  def attendance_detail_url
    url = ENV['attendance_url'] || CONFIG['attendance-url']
    "#{url}/stats?#{attendance_report_query.to_query}&distribution=instructor"
  end

  def system_tag(name)
    business.tags.where(system_name: name).first
  end

  def installments_tag
    @installments_tag ||= system_tag("installment")
  end

  def agent_installments_collection_by_presence_total(agent)
    acum = 0
    contacts_in_attendance_report.each do |contact|
      contact_detail = attendance_report[contact.padma_id] || {}
      contact_paid = total_for_tag(installments_tag,nil,{contact_id: contact.id})
      per = (contact_detail[agent.padma_id.gsub(".","_")].try(:to_f) || 0)*100
      acum += per * contact_paid / 100
    end
    acum
  end

  def sales_tag
    @sales_tag ||= system_tag("sale")
  end

  def agent_sales_comission(agent)
    total_for_tag(sales_tag, agent.id) * (agent_sale_percentage || 0) / 100
  end

  def sales_total_discount
    acum = 0
    team_members.each do |tm|
      acum += agent_sales_comission(tm)
    end
    acum 
  end

  def enrollments_tag
    @enrollments_tag ||= system_tag("enrollment")
  end

  def agent_enrollments_comission(agent)
    total_for_tag(enrollments_tag, agent.id) * (agent_enrollment_income_percentage || 0) / 100
  end

  def agent_enrollments_prize(agent)
    (enrollments_by_teacher[agent.padma_id] || 0) * (agent_enrollment_quantity_fixed_amount || 0)
  end

  def agent_from_enrollments_total(agent)
    agent_enrollments_comission(agent) + agent_enrollments_prize(agent)
  end

  def enrollments_total_discount
    acum = 0
    team_members.each do |tm|
      acum += agent_from_enrollments_total(tm)
    end
    acum
  end

  # @return Integer enrollments on given month
  # @return nil on error
  def enrollments_by_teacher
    cache_key = [id,ref_date,"enrollments_by_teacher"]
    report = Rails.cache.read(cache_key)
    if report && !force_refresh
      report
    else
      url = ENV["overmind_url"] || CONFIG["overmind-url"]
      key = ENV["overmind_key"] || CONFIG["overmind_key"]

      response = HTTParty.get("#{url}/api/v0/monthly_stats",query: {
        api_key: key,
        where: {
          type: 'TeacherMonthlyStat',
          year: ref_date.year,
          month: ref_date.month,
          account_name: business.padma_id,
          name: 'enrollments'
        }
      }) 
      if response.code == 200
        report = {}
        response.parsed_response["collection"].each do |stat|
          report[stat["teacher_username"]] = stat["value"]
        end
        Rails.cache.write(cache_key,report,expires_in: 1.hour)
        report
      else
        nil
      end
    end
  rescue Errno::ECONNREFUSED => e
    nil
  end
  
  private

  def attendance_report_query
    {
      stats: {
        start_on: ref_date.beginning_of_month,
        end_on: ref_date.end_of_month,
        include_former_students: 1,
        include_cultural_activities: 1
      }
    }
  end

  def set_defaults
    self.owners_percentage = 50 if self.owners_percentage.nil?
  end

end
