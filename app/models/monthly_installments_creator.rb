class MonthlyInstallmentsCreator
  attr_accessor :business

  def initialize(business)
    @business = business
  end

  def run
    business.students.each do |student|
      unless student.installment_for(Date.today)
        # TODO: get Agent for new installment using padma teacher
        # student.membership.installments.create(:)
      end
    end
  end
end