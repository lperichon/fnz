FactoryGirl.define do

  sequence :tag_name do |n|
    "tag #{n}"
  end

  factory :tag do |f|
    business
    name  { FactoryGirl.generate :tag_name }
  end
end
