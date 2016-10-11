FactoryGirl.define do
  factory :test_en_intent do
    content { Faker::Company.name }
  end
  factory :test_ja_intent do
    content { Faker::Company.name }
  end
end
