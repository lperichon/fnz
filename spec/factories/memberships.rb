# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership do |f|
    business
    contact {FactoryGirl.create(:contact, :business => self.business)}
    begins_on {Date.today.beginning_of_month}
    ends_on   {11.months.from_now.end_of_month}
    monthly_due_day 10
  end
end