class MonthlyInstallmentsCreator
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.contacts.students.each do |student|
      unless student.padma_teacher.blank? || student.installment_for(Date.today).present? || student.membership.blank?
        agent = business.agents.where(:padma_id => student.padma_teacher).first
        student.current_membership.installments.create(:agent_id => agent.id,
                                               :due_on => Date.today.end_of_month,
                                               :value => student.membership.value) if agent
      end
    end
  end
end