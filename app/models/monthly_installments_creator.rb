class MonthlyInstallmentsCreator
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.contacts.students.each do |student|
      current_membership = student.current_membership
      unless student.installment_for(Date.today).present? || current_membership.blank?
        
        agent = business.agents.where(:padma_id => student.padma_teacher).first

        installment = current_membership.installments.new(:due_on => Date.today.end_of_month,
                                                          :value => student.membership.value)
        
        installment.agent = agent if agent

        installment.save
      end
    end
  end
end