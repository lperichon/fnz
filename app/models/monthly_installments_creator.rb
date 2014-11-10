class MonthlyInstallmentsCreator
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.contacts.students.each do |student|
      current_membership = student.current_membership
      unless student.installment_for(Date.today).present? || current_membership.blank? || current_membership.overdue?
        
        agent = business.agents.enabled.where(:padma_id => student.padma_teacher).first

        installment = current_membership.installments.new(:due_on => Date.new(Date.today.year,Date.today.month,current_membership.monthly_due_day),
                                                          :value => current_membership.value)
        
        installment.agent = agent if agent

        installment.save
      end
    end
  end
end