require 'appsignal'
require 'appsignal/integrations/object'

class Admpart < ActiveRecord::Base
  
  attr_accessible :director_from_profit_percentage,          # % del lucro para director 
                  :owners_percentage,                        # % para inversores
                  :dir_from_owners_aft_expses_percentage,    # % de inversores para director
                  :agent_sale_percentage,                    # % de la venta para instructor
                  :agent_enrollment_income_percentage,       # % de recaudación x matrículas para instructor
                  :agent_enrollment_quantity_fixed_amount,   # valor fijo x matricula para instructor
                  :agent_installments_attendance_percentage, # % de recaudación x alumno que va segun presencia, el resto va x vinculo transaccion-agente
                  :installments_tag_id,
                  :enrollments_tag_id,
                  :sales_tag_id,
                  :ref_date

  belongs_to :business

  [:owners_percentage,
   :director_from_profit_percentage,
   :dir_from_owners_aft_expses_percentage,
   :agent_sale_percentage,
   :agent_enrollment_income_percentage,
   :agent_installments_attendance_percentage
  ].each do |per|
    validates per,
              allow_blank: true,
              numericality: {
                only_integer: true,
                greather_than_or_equal_to: 0,
                less_than_or_equal_to: 100
              }
  end

  before_validation :force_ref_date_to_first_day_of_month
  validates :ref_date, presence: true, uniqueness: { scope: :business_id } 
  validate :ref_date_first_day_of_month

  attr_accessor :force_refresh


  VALID_SECTIONS = %W(income expense ignore director_expenses owners_expenses teams_expenses equal_distribution)

  before_save :set_defaults

  def self.for_ref_date(rd)
    self.where(ref_date: rd.to_date.beginning_of_month)
  end

  IGNORED_ATTRIBUTES_IN_CLONE = %W(id ref_date business_id created_at updated_at)
  def self.get_for_ref_date(rd)
    ret = self.for_ref_date(rd).first
    if ret.nil?
      clone_ref = self.for_ref_date(rd-1.month).first || self.for_ref_date(rd+1.month).first || self.first
      ret = if clone_ref
        self.create( clone_ref.attributes_for_clone.merge( ref_date: rd ) )
      else
        self.create(ref_date: rd)
      end
    end
    ret
  end
  def attributes_for_clone
    attributes.reject{|k| k.in?(IGNORED_ATTRIBUTES_IN_CLONE) }
  end

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
    total_before_owner - teams_pre_expenses_amount # substract in case profit < 0 and teams_pre_expenses_amount was forced to 0
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
    ret = total_before_owner * teams_percentage / 100
    (ret < 0)? 0 : ret
  end

  def teams_final_amount
    @teams_final_amount ||= (teams_pre_expenses_amount + section_total("teams_expenses"))
  end

  def team_members
    if @team_members
      @team_members
    else
      @team_members ||= business.agents.enabled.select{|a| !a.padma_id.blank? }
    end
  end

  def agent_total_collection(agent)
    # considering only INSTALLMENTS
    agent_installments_collection_total(agent)
  end

  def agent_from_team_final_amount_percentage(agent)
    # considering only INSTALLMENTS
    (agent_installments_collection_total(agent) / total_for_tag(installments_tag)) * 100
  end

  def agent_from_team_final_amount(agent)
    # considering only INSTALLMENTS
    agent_from_team_final_amount_percentage(agent) * teams_final_amount / 100
  end

  def agent_from_equal_distribution_section # agent not needed, its EQUAL distribution
    @afeds ||= (section_total("equal_distribution") / team_members.size)
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

  def transactions_for_tag(tag,options={})
    return [] if tag.nil?
    tags = tag.self_and_descendants
    scope = business.transactions
                    .to_report_on_month(ref_date)
                    .where(admpart_tag_id: tags.map(&:id))
    if options[:agent_id] == ""
      scope = scope.where(agent_id: nil)
    elsif options[:agent_id]
      scope = scope.where(agent_id: options[:agent_id])
    end

    if options[:contact_id] == ""
      scope = scope.where(contact_id: nil)
    elsif options[:contact_id]
      scope = scope.where(contact_id: options[:contact_id])
    end
    scope
  end

  def total_for_tag(tag,agent_id=nil,options={})
    options_digest = Digest::MD5.hexdigest(options.to_param) 
    cache_key = [id,"total_for_tag",tag.id,options_digest]
    unless agent_id.nil?
      cache_key << "agent:#{agent_id}"
    end

    @total = Rails.cache.read(cache_key)
    if @total && !force_refresh
      @total
    else
      @total = 0

      # TODO consider currencies
      # TODO consider state of transaction. maybe no need?
      
      scope = transactions_for_tag(tag, options.merge({ agent_id: agent_id }))
      @total += scope.credits.sum(:amount)
      @total -= scope.debits.sum(:amount)

      if agent_id.nil? && !options[:ignore_discounts]
        case tag.system_name
        when "sale" 
          @total -= sales_total_discount
        when "enrollment"
          @total -= enrollments_total_discount
        end
      end

      Rails.cache.write(cache_key, @total, expires_in: 10.minutes)
      @total
    end
  end
  appsignal_instrument_method :total_for_tag

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
  appsignal_instrument_method :attendance_report

  def contacts_in_attendance_report
    @contacts_in_attendance_report ||= business.contacts.where(padma_id: attendance_report.keys)
  end

  def attendance_detail_url
    url = ENV['attendance_url'] || CONFIG['attendance-url']
    "#{url}/stats?#{attendance_report_query.to_query}&distribution=instructor"
  end

  def system_tag(name)
    business.tags.get_system_tag(name)
  end

  def installments_tag
    @installments_tag ||= system_tag("installment")
  end

  def agent_installments_link_percentage
    100 - (agent_installments_attendance_percentage || 0)
  end

  def agent_installments_collection_by_link_total(agent)
    acum = 0
    contacts_in_attendance_report.each do |contact|
      contact_detail = attendance_report[contact.padma_id] || {}
      acum += total_for_tag(installments_tag,agent.id,{contact_id: contact.id}) * agent_installments_link_percentage / 100
    end
    acum
  end

  def agent_installments_collection_by_presence_total(agent)
    acum = 0
    contacts_in_attendance_report.each do |contact|
      contact_detail = attendance_report[contact.padma_id] || {}
      distributable_contact_payment = total_for_tag(installments_tag,nil,{contact_id: contact.id}) * (agent_installments_attendance_percentage || 0) / 100
      per = (contact_detail[agent.padma_id.gsub(".","_")].try(:to_f) || 0)*100
      acum += per * distributable_contact_payment / 100
    end
    acum
  end
  appsignal_instrument_method :agent_installments_collection_by_presence_total
  
  def agent_installments_collection_total(agent)
    agent_installments_collection_by_presence_total(agent) + agent_installments_collection_by_link_total(agent)
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
    if @enrollments_by_teacher
      @enrollments_by_teacher
    else
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
    end
  rescue Errno::ECONNREFUSED => e
    nil
  end
  appsignal_instrument_method :enrollments_by_teacher

  def agent_total_winnings(agent)
    agent_from_team_final_amount(agent) + agent_sales_comission(agent) + agent_from_enrollments_total(agent) + agent_from_equal_distribution_section
  end

  # installments_tag_id, enrollments_tag_id, sales_tag_id getter and setter
  Tag::VALID_SYSTEM_NAMES.each do |sysname|
    define_method "#{sysname}s_tag_id" do
      send("#{sysname}s_tag").try(:id)
    end
  end

  def queue_refresh_cache
    queued_job = Delayed::Job.where("handler like '%Admpart%id: #{id}%refresh_cache'").last
    if queued_job.nil?
      queued_job = delay.refresh_cache(ref_date) 
    end
    queued_job
  end

  # refreshes cache by calling methods with force_refresh=true
  def refresh_cache(ref_date)
    bckup = self.force_refresh
    self.force_refresh = true

    # webservices calls
    attendance_report
    enrollments_by_teacher

    # DB queries
    VALID_SECTIONS.each{|s| section_total(s) }    
    team_members.each{|tm| agent_total_winnings(tm) }

    self.force_refresh = bckup
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
    self.ref_date = Time.zone.today.beginning_of_month if self.ref_date.nil?
    self.owners_percentage = 50 if self.owners_percentage.nil?
  end

  def ref_date_first_day_of_month
    if ref_date && ref_date.day != 1
      errors.add(:ref_date, "must be first day of month")
    end
  end

  def force_ref_date_to_first_day_of_month
    if ref_date && ref_date.day != 1
      self.ref_date= ref_date.beginning_of_month
    end
  end

end
