class MembershipStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business, :month, :year, :membership_filter

  validates_presence_of :business, :month, :year

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def ref_date
    @ref_date ||= Date.civil(year,month,1)
  end

  def persisted?
    false
  end

  def enrollments
    memberships.joins(:enrollment).joins(:enrollment => :transactions).where("enrolled_on >= '#{ref_date.beginning_of_month.beginning_of_day}' AND enrolled_on <= '#{ref_date.end_of_month.end_of_day}'").select("SUM(CASE WHEN transactions.amount >= enrollments.value THEN enrollments.value ELSE transactions.amount END) AS sum")
  end

  def all_installments
    memberships.joins(:installments).where("due_on >= '#{ref_date.to_date.beginning_of_month.beginning_of_day}' AND due_on <= '#{ref_date.end_of_month.end_of_day}'").select("SUM(installments.value) AS sum, AVG(installments.value) AS avg")
  end

  def all_including_projections(agent=nil)
    is = memberships.joins(:installments)
               .where("due_on >= :first_day_of_month AND due_on <= :last_day_of_month",
                         first_day_of_month: ref_date,
                         last_day_of_month: ref_date.end_of_month
                     )
    if agent
      if agent == ""
        is = is.where(installments: {agent_id: nil})
      else
        is = is.where(installments: {agent_id: agent.id})
      end
    end
    is.select("SUM(installments.value) AS sum")

    ms = memberships.wout_installments
               .valid_on(ref_date)
    if agent
      if agent == ""
        ms = ms.joins(:contact).where(contacts: { padma_teacher: nil })
      else
        ms = ms.joins(:contact).where(contacts: { padma_teacher: agent.padma_id })
      end
    end
    ms.select("SUM(memberships.value) AS sum")

    total_sum = is.sum("installments.value") + ms.sum("memberships.value")
    total_avg = total_sum / (is.count + ms.count)

    { sum: total_sum, avg: total_avg }
  end

  def paid_installments
    memberships.joins(:installments).joins(:installments => :transactions).where("transactions.report_at >= '#{ref_date.to_date.beginning_of_month.beginning_of_day}' AND transactions.report_at <= '#{ref_date.end_of_month.end_of_day}'").select("SUM(CASE WHEN (installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS sum, AVG(CASE WHEN (installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS avg")
  end

  def memberships
    if @memberships
      @memberships
    else
      if @membership_filter.nil?
        @memberships = Membership.unscoped.where(business_id: business.id)
      else
        # includes(:memberships) to avoid N-queries
        @memberships = Membership.unscoped.where(business_id: business.id).where(:id => @membership_filter.results.includes(:memberships).collect {|c| c.membership_ids })
      end
      @memberships
    end
  end
end
