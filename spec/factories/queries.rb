FactoryGirl.define do
  factory :training_en_query do
    content { Faker::Lorem.sentence }
    after(:create) do |query|
      3.times do |n|
        query.iunits << create(:training_en_iunit,
          uid: "#{query.qid}-%04d" % (n+1),
          content: Faker::Lorem.sentence,
          qid: query.qid,
          importance: n,
          query_id: query.id)
      end
    end
  end

  factory :training_en_query_without_iunits, class: TrainingEnQuery do
    content { Faker::Lorem.sentence }
  end

  factory :training_ja_query do
    content { Faker::Lorem.sentence }
    after(:create) do |query|
      3.times do |n|
        query.iunits << create(:training_ja_iunit,
          uid: "#{query.qid}-%04d" % (n+1),
          content: Faker::Lorem.sentence,
          qid: query.qid,
          importance: n,
          query_id: query.id)
      end
    end
  end

  factory :test_en_query do
    content { Faker::Lorem.sentence }

    after(:create) do |query|
      4.times do |n|
        query.iunits << create(:test_en_iunit,
          uid: "#{query.qid}-%04d" % (n+1),
          content: Faker::Lorem.sentence,
          qid: query.qid,
          importance: n,
          query_id: query.id)
      end
    end

    trait :summarization do
      after(:create) do |query|
        query.iunits.delete_all
        query.reload
        20.times do |n|
          create(:test_en_iunit,
            uid: "#{query.qid}-%04d" % (n+1),
            content: "XX",
            qid: query.qid,
            importance: n,
            query_id: query.id)
        end

        5.times do |n|
          create(:test_en_intent,
            iid: query.qid + "-INTENT000#{n+1}",
            qid: query.qid,
            content: "XXXXX",
            probability: n / 10.0,
            query_id: query.id)
        end

        query.intents.each_with_index do |intent, iidx|
          query.iunits.each_with_index do |iunit, uidx|
            create(:test_en_judge,
              qid: query.qid,
              iid: intent.iid,
              uid: iunit.uid,
              importance: iidx + uidx,
              query_id: query.id,
              intent_id: intent.id,
              iunit_id: iunit.id)
          end
        end

      end
    end
  end

  factory :test_ja_query do
    content { Faker::Lorem.sentence }

    after(:create) do |query|
      4.times do |n|
        query.iunits << create(:test_ja_iunit,
          uid: "#{query.qid}-%04d" % (n+1),
          content: Faker::Lorem.sentence,
          qid: query.qid,
          importance: n,
          query_id: query.id)
      end
    end

    trait :summarization do
      after(:create) do |query|
        query.iunits.delete_all
        query.reload
        20.times do |n|
          create(:test_ja_iunit,
            uid: "#{query.qid}-%04d" % (n+1),
            content: "XX",
            qid: query.qid,
            importance: n,
            query_id: query.id)
        end

        5.times do |n|
          create(:test_ja_intent,
            iid: query.qid + "-INTENT000#{n+1}",
            qid: query.qid,
            content: "XXXXX",
            probability: n / 10.0,
            query_id: query.id)
        end

        query.intents.each_with_index do |intent, iidx|
          query.iunits.each_with_index do |iunit, uidx|
            create(:test_ja_judge,
              qid: query.qid,
              iid: intent.iid,
              uid: iunit.uid,
              importance: iidx + uidx,
              query_id: query.id,
              intent_id: intent.id,
              iunit_id: iunit.id)
          end
        end

      end
    end

  end

end

