# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :membership_stats do
    business
    year {2013}
    month {3}
  end
end
