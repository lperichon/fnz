# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@mail.com"
  end

  factory :user, :aliases => [:owner] do
    name 'Test User'
    email
  end
end