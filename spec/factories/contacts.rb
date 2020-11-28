# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :contact do
    name {'Test Contact'}
    business
  end
end
