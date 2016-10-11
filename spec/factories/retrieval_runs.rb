FactoryGirl.define do
  factory :training_retrieval_en_run do
    runtype { :training_retrieval_en }
    filepath { "#{Rails.root}/spec/fixtures/runs/training_retrieval_en.tsv" }
    group_name { "TEST" }
    agree { true }
    description { "this is a test run" }
    is_open { true }
  end

  factory :test_retrieval_en_run do
    runtype { :test_retrieval_en }
    filepath { "#{Rails.root}/spec/fixtures/runs/test_retrieval_en.tsv" }
    group_name { "TEST" }
    agree { true }
    description { "this is a test run" }
    is_open { true }
  end

end

