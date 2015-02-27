class MonthlyInstallmentsCreator
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.contacts.students.each do |student|
      current_membership = student.current_membership
      installment = student.installment_for(Date.today)
      
      if installment.present?
        # Update agent on already existing installments
        agent = business.agents.enabled.where(:padma_id => student.padma_teacher).first
        if agent
          installment.agent = agent
          installment.save
        end
      elsif current_membership.present? and Date.today >= current_membership.begins_on and not current_membership.overdue?
        # create installment
        agent = business.agents.enabled.where(:padma_id => student.padma_teacher).first
        installment = current_membership.installments.new(:due_on => Date.new(Date.today.year,Date.today.month,current_membership.monthly_due_day),
                                                          :value => current_membership.value)
        installment.agent = agent if agent
        installment.save
      end
    end
  end
end