# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :sale do
    contact
    business
    agent
    sold_on {Date.today}
  end
end
