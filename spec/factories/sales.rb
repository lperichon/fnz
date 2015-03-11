# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sale do
    contact
    business
    agent
    sold_on Date.today
  end
end
