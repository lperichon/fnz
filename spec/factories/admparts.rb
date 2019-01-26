# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admpart do
    ref_date { Date.today }
    business
  end
end
