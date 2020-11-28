# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :admpart do
    ref_date { Date.today }
    business
  end
end
