require 'rails_helper'
require 'rake'

describe 'rake import' do

  before :all do
    @rake = Rake.application
  end

  after(:all) do
    # clean manually
    DatabaseRewinder.clean
    FactoryGirl.reload
  end

  describe 'import:training_data' do
    folderpath = '/tmp/MC2-training'
    filepath = "#{folderpath}/en/1C2-E-queries.tsv"

    before :all do
      @rake['import:training_data'].execute
    end

    it 'downloads the data' do
      expect(File.exists?(filepath)).to be_truthy
    end

    it 'deletes the current data' do
      q = TrainingEnQuery.create(qid: "Dummy", content: "Dummy")
      i = TrainingEnIunit.create(qid: "Dummy", uid: "Dummy", query_id: q.id)
      @rake['import:training_data'].execute
      expect{ TrainingEnQuery.find(q.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ TrainingEnIunit.find(i.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'loads 100 queries and 4342 iunits for English' do
      expect(TrainingEnQuery.count).to eq(100)
      expect(TrainingEnIunit.count).to eq(4342)
      expect(TrainingEnQuery.includes(:iunits).map {|q| q.iunits.size}.sum).to eq(4342)
    end

    it 'loads 100 queries and 5324 iunits for Japanese' do
      expect(TrainingJaQuery.count).to eq(100)
      expect(TrainingJaIunit.count).to eq(5324)
      expect(TrainingJaQuery.includes(:iunits).map {|q| q.iunits.size}.sum).to eq(5324)
    end

    it 'loads correct queries' do
      expect(TrainingEnQuery.find_by(qid: '1C2-E-0010').content).to eq("rodney atkins")
      expect(TrainingJaQuery.find_by(qid: '1C2-J-0010').content).to eq("マイケル ジャクソン 死")
    end

    it 'loads correct iunits' do
      expect(TrainingEnIunit.find_by(uid: '1C2-E-0010-0010').content).to eq("dad survived")
      expect(TrainingJaIunit.find_by(uid: '1C2-J-0010-0010').content).to eq("ロサンゼルス検視当局が故殺であると断定した")
    end

    it 'loads correct weights' do
      expect(TrainingEnIunit.find_by(uid: '1C2-E-0010-0010').importance).to eq(5)
      expect(TrainingJaIunit.find_by(uid: '1C2-J-0010-0010').importance).to eq(8)
    end
  end

  describe 'import:test_data' do
    let(:task) { 'import:test_data' }
    folderpath = '/tmp/MC2-test'
    filepath = "#{folderpath}/en/MC2-E-queries.tsv"

    before :all do
      @rake['import:test_data'].execute
    end

    it 'downloads the data' do
      expect(File.exists?(filepath)).to be_truthy
    end

    it 'deletes the current data' do
      q = TestEnQuery.create!(qid: "Dummy", content: "Dummy")
      u = TestEnIunit.create!(qid: "Dummy", uid: "Dummy", 
        content: "Dummy", importance: 0, query_id: q.id)
      i = TestEnIntent.create!(qid: "Dummy", iid: "Dummy", 
        content: "Dummy", probability: 0, query_id: q.id)
      j = TestEnJudge.create!(qid: "Dummy", iid: "Dummy", uid: "Dummy",
        importance: 0, query_id: q.id, intent_id: i.id, iunit_id: u.uid)

      @rake['import:test_data'].execute
      expect{ TestEnQuery.find(q.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ TestEnIunit.find(u.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ TestEnIunit.find(i.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ TestEnJudge.find(j.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'loads 100 queries and 4342 iunits for English' do
      expect(TestEnQuery.count).to eq(100)
      expect(TestEnIunit.count).to eq(2317)
      expect(TestEnQuery.includes(:iunits).map {|q| q.iunits.size}.sum).to eq(2317)
    end

    it 'loads 100 queries and 5324 iunits for Japanese' do
      expect(TestJaQuery.count).to eq(100)
      expect(TestJaIunit.count).to eq(4169)
      expect(TestJaQuery.includes(:iunits).map {|q| q.iunits.size}.sum).to eq(4169)
    end

    it 'loads correct queries' do
      expect(TestEnQuery.find_by(qid: 'MC2-E-0010').content).to eq("gareth bale")
      expect(TestJaQuery.find_by(qid: 'MC2-J-0010').content).to eq("能年玲奈")
    end

    it 'loads correct iunits' do
      expect(TestEnIunit.find_by(uid: 'MC2-E-0010-0010').content).to eq("born 16 July 1989")
      expect(TestJaIunit.find_by(uid: 'MC2-J-0010-0010').content).to eq("第17回日刊スポーツドラマグランプリ・主演女優賞『あまちゃん』")
    end

    it 'loads 448 intents for English' do
      expect(TestEnIntent.count).to eq(448)
      expect(TestEnQuery.includes(:intents).map {|q| q.intents.size}.sum).to eq(448)
    end

    it 'loads 437 intents for Japanese' do
      expect(TestJaIntent.count).to eq(437)
      expect(TestJaQuery.includes(:intents).map {|q| q.intents.size}.sum).to eq(437)
    end

    it 'loads all the judges' do
      {TestEnQuery => TestEnJudge, TestJaQuery => TestJaJudge}.each do |qcls, jcls|
        judges = jcls.all.index_by {|j| [j.iid, j.uid]}
        queries = qcls.includes(:intents, :iunits).all
        queries.each do |q|
          q.intents.each do |i|
            q.iunits.each do |u|
              expect(judges).to have_key([i.iid, u.uid])
            end
          end
        end
        expect(judges.size).to eq(queries.map {|q| q.intents.size * q.iunits.size}.sum)
      end
    end

    it 'loads correct iunits' do
      expect(TestEnIntent.find_by(iid: 'MC2-E-0010-INTENT0001').content).to eq("Profile")
      expect(TestJaIntent.find_by(iid: 'MC2-J-0010-INTENT0001').content).to eq("人物")
    end

    it 'loads correct probability' do
      expect(TestEnIntent.where('probability > ?', 0).count).to be > 0
      TestEnIntent.all.group_by(&:qid).each do |qid, intents|
        expect(intents.map {|i| i.probability}.sum).to almost_eq(1.0, 5)
      end
      expect(TestJaIntent.where('probability > ?', 0).count).to be > 0
      TestJaIntent.all.group_by(&:qid).each do |qid, intents|
        expect(intents.map {|i| i.probability}.sum).to almost_eq(1.0, 5)
      end
    end

    it 'loads correct judges' do
      expect(TestEnJudge.where('importance > ?', 0).count).to be > 0
      expect(TestJaJudge.where('importance > ?', 0).count).to be > 0
      expect(TestEnJudge.where('importance >= ?', 0).count).to eq TestEnJudge.count
      expect(TestJaJudge.where('importance >= ?', 0).count).to eq TestJaJudge.count
    end

    it 'loads correct importance' do
      expect(TestEnIunit.where('importance > ?', 0).count).to be > 0
      expect(TestJaIunit.where('importance > ?', 0).count).to be > 0
    end

    it 'loads correct global importance = intent_probability * per_intent_importance' do
      [
        [TestEnIunit, TestEnIntent, TestEnJudge],
        [TestJaIunit, TestJaIntent, TestJaJudge]
      ].each do |uij|
        ucls, icls, jcls = uij
        iunits = ucls.all
        intents = icls.all.index_by(&:iid)
        judges = jcls.all

        result = Hash.new(0.0)
        judges.each do |j|
          result[j.uid] += intents[j.iid].probability * j.importance
        end
        iunits.each do |u|
          expect(u.importance).to eq(result[u.uid])
        end
      end
    end
  end

end
