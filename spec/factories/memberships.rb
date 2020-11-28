# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :membership do |f|
    business
    contact {FactoryBot.create(:contact, :business => self.business)}
    begins_on {Date.today.beginning_of_month}
    ends_on   {11.months.from_now.end_of_month}
    payment_type { FactoryBot.create(:payment_type) }
    monthly_due_day {10}
    value {100}
  end
end
