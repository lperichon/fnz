# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  sequence :email do |n|
    "email#{n}@mail.com"
  end

  factory :user, :aliases => [:owner] do
    name {'Test User'}
    drc_uid {'test.user'}
    email
  end
end
