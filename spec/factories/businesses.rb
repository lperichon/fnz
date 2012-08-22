# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :business do
    name 'Test Business'
    owner FactoryGirl(:user)
  end
end