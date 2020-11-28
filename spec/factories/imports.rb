# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :import do
    business
  end

  factory :product_import do
    business
    type {"ProductImport"}
  end
end
