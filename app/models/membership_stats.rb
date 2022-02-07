class MembershipStats
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :business,
                :month, :year,
                :membership_filter,
                :only_current

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
    is = is_scope(agent)
    ms = ms_scope(agent)
    total_sum = (is.sum("installments.value_cents") + ms.sum("memberships.value_cents")) / 100.0
    total_avg = total_sum / (is.count + ms.count)

    { sum: total_sum, avg: total_avg }
  end
  def is_scope(agent=nil)
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
    is
  end
  def ms_scope(agent=nil)
   ms = memberships
   if is_scope(agent).count > 0
     ms = memberships.where("memberships.id not in (?)", is_scope(agent).pluck("installments.membership_id"))  #wout_installments_due_on_month(ref_date)
   end
   ms = ms.valid_on(ref_date)

   if agent
     if agent == ""
       ms = ms.joins(:contact).where(contacts: { padma_teacher: nil })
     else
       ms = ms.joins(:contact).where(contacts: { padma_teacher: agent.padma_id })
     end
   end
   ms
  end

  def paid_installments
    paid_installments_scope
    .select("SUM(CASE WHEN ((installments.status IS NULL) OR installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS sum, AVG(CASE WHEN ((installments.status IS NULL) OR installments.status = 'overdue' OR installments.status = 'incomplete') AND installments.balance < installments.value THEN installments.balance ELSE installments.value END) AS avg") # esto CUENTA los pending
  end

  def paid_installments_scope
    memberships.joins(:installments)
               .joins(:installments => :trans)
               .where("transactions.report_at >= '#{ref_date.to_date.beginning_of_month}' AND transactions.report_at <= '#{ref_date.end_of_month}'")
  end

  def total_for_installments(agent=nil)
    adm = business.admparts.get_for_ref_date(ref_date)
    agent_id = (agent=="")? "" : agent.try(:id)
    adm.total_for_tag(adm.installments_tag,agent_id,{contact_id: @membership_filter.results.map(&:id)})
  end

  def memberships
    if @memberships
      @memberships
    else
      scope = Membership.unscoped.where(business_id: business.id)
      if @membership_filter.nil?
        if @only_current
          scope = scope.joins("contacts ON contacts.current_membership_id=memberships.id")
        end
        @memberships = scope
      else
        ids_method = if @only_current
          "current_membership_id"
        else
          "membership_ids"
        end
        # includes(:memberships) to avoid N-queries when calling membership_ids
        @memberships = scope.where(id: @membership_filter.results
                                                         .includes(:memberships)
                                                         .collect {|c| c.send(ids_method) }
                                                         .flatten
                                  )
      end
    end
  end
end
