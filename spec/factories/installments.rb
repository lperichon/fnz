# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :installment do
    membership
    due_on 1.week.from_now
    value 100
  end
end