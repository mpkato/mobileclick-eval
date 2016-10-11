FactoryGirl.define do
  factory :test_summarization_en_run do
    runtype { :test_summarization_en }
    filepath { "#{Rails.root}/spec/fixtures/runs/test_summarization_en.xml" }
    group_name { "TEST" }
    agree { true }
    is_open { false }
  end
end


