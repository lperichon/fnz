FactoryBot.define do

  sequence :tag_name do |n|
    "tag #{n}"
  end

  factory :tag do |f|
    business
    name  { FactoryBot.generate :tag_name }
  end
end
