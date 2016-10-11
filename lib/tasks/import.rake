namespace :import do
  DIR = '/tmp/'
  EVAL_DIR = "#{Rails.root}/"

  # Training
  TRAINING_FILEPATH = DIR + 'MC2-training.tar.gz'
  TRAINING_FOLDERPATH = DIR + 'MC2-training/'

  TRAINING_J_QUERY_PATH = 'ja/1C2-J-queries.tsv'
  TRAINING_J_IUNIT_PATH = 'ja/1C2-J-iunits.tsv'
  TRAINING_J_WEIGHT_PATH = 'ja/1C2-J-weights.tsv'

  TRAINING_E_QUERY_PATH = 'en/1C2-E-queries.tsv'
  TRAINING_E_IUNIT_PATH = 'en/1C2-E-iunits.tsv'
  TRAINING_E_WEIGHT_PATH = 'en/1C2-E-weights.tsv'

  # Test
  TEST_FILEPATH = DIR + 'MC2-test.tar.gz'
  TEST_FOLDERPATH = DIR + 'MC2-test/'
  TEST_EVAL_FOLDERPATH = EVAL_DIR + 'MC2-test-eval/'

  TEST_J_QUERY_PATH = 'ja/MC2-J-queries.tsv'
  TEST_J_IUNIT_PATH = 'ja/MC2-J-iunits.tsv'
  TEST_J_INTENT_PATH = 'ja/MC2-J-intents.tsv'
  TEST_J_IMPORTANCE_PATH = 'ja/MC2-J-importance.tsv'
  TEST_J_PROBABILITY_PATH = 'ja/MC2-J-probability.tsv'

  TEST_E_QUERY_PATH = 'en/MC2-E-queries.tsv'
  TEST_E_IUNIT_PATH = 'en/MC2-E-iunits.tsv'
  TEST_E_INTENT_PATH = 'en/MC2-E-intents.tsv'
  TEST_E_IMPORTANCE_PATH = 'en/MC2-E-importance.tsv'
  TEST_E_PROBABILITY_PATH = 'en/MC2-E-probability.tsv'

  def import_query(cls, folderpath, query_path)
    cls.delete_all
    queries = []
    CSV.foreach(folderpath + query_path, col_sep: "\t") do |row|
      qid = row[0]
      content = row[1]
      q = cls.new(qid: qid, content: content)
      queries << q
    end
    cls.import queries
    result = cls.all.index_by(&:qid)
    return result
  end

  def import_training_iunits(cls, folderpath, iunit_path, weight_path, queries)
    cls.delete_all
    iunits = parse_iunits(cls, folderpath, iunit_path)

    result = []
    CSV.foreach(folderpath + weight_path, col_sep: "\t") do |row|
      qid = row[0]
      uid = row[1]
      weight = row[2].to_f
      iunit = iunits[qid][uid]
      iunit.importance = weight
      iunit.query = queries[qid]
      result << iunit
    end
    cls.import result
    result = cls.all.index_by(&:uid)
    return result
  end

  def import_test_iunits(cls, folderpath, iunit_path, queries)
    cls.delete_all
    iunits = parse_iunits(cls, folderpath, iunit_path)

    result = []
    queries.each do |qid, query|
      next unless iunits.include?(qid) # for MC2-J-0083
      iunits[qid].values.each do |iunit|
        iunit.query = query
        iunit.importance = 0 # WARNING!
        result << iunit
      end
    end
    cls.import result
    result = cls.all.index_by(&:uid)
    return result
  end

  def import_intents(cls, folderpath, intent_path,
    eval_folderpath, probability_path, queries)
    cls.delete_all
    intents = {}
    CSV.foreach(folderpath + intent_path, col_sep: "\t") do |row|
      qid = row[0]
      iid = row[1]
      content = row[2]
      (intents[qid] ||= {})[iid] = cls.new(qid: qid, iid: iid, content: content)
    end

    result = []
    CSV.foreach(eval_folderpath + probability_path, col_sep: "\t") do |row|
      qid = row[0]
      iid = row[1]
      probability = row[2].to_f
      intent = intents[qid][iid]
      intent.probability = probability
      intent.query = queries[qid]
      result << intent
    end

    cls.import result
    result = cls.all.index_by(&:iid)
    return result
  end

  def import_judges(cls, eval_folderpath, importance_path,
    queries, iunits, intents)
    cls.delete_all

    result = []
    CSV.foreach(eval_folderpath + importance_path, col_sep: "\t") do |row|
      qid = row[0]
      iid = row[1]
      uid = row[2]
      importance = row[3]
      judge = cls.new(qid: qid, iid: iid, uid: uid, importance: importance)
      judge.query = queries[qid]
      judge.iunit = iunits[uid]
      judge.intent = intents[iid]
      result << judge
    end

    cls.import result
    result = cls.all.index_by {|j| [j.iid, j.uid]}
    return result
  end

  def update_test_iunit_weight(iunits, intents, judges)
    importances = Hash.new(0.0)
    judges.values.each do |judge|
      importances[judge.uid] += intents[judge.iid].probability * judge.importance
    end
    iunits.each do |uid, iunit|
      iunit.update(importance: importances[uid])
    end
  end

  def download_data(url, filepath)
    sh "wget #{url} -O #{filepath} -q"
    sh "tar fzxv #{filepath} -C #{DIR}"
  end

  def parse_iunits(cls, folderpath, iunit_path)
    result = {}
    CSV.foreach(folderpath + iunit_path, col_sep: "\t") do |row|
      qid = row[0]
      uid = row[1]
      content = row[2]
      (result[qid] ||= {})[uid] = cls.new(qid: qid, uid: uid, content: content)
    end
    return result
  end

  desc "Import training data"
  task :training_data => :download_training_data do
    queries = import_query(TrainingJaQuery, TRAINING_FOLDERPATH, TRAINING_J_QUERY_PATH)
    import_training_iunits(TrainingJaIunit,
      TRAINING_FOLDERPATH, TRAINING_J_IUNIT_PATH, TRAINING_J_WEIGHT_PATH, queries)

    queries = import_query(TrainingEnQuery, TRAINING_FOLDERPATH, TRAINING_E_QUERY_PATH)
    import_training_iunits(TrainingEnIunit,
      TRAINING_FOLDERPATH, TRAINING_E_IUNIT_PATH, TRAINING_E_WEIGHT_PATH, queries)
  end

  desc "Import test data"
  task :test_data => [:download_test_data] do
    queries = import_query(TestJaQuery, TEST_FOLDERPATH, TEST_J_QUERY_PATH)
    iunits = import_test_iunits(TestJaIunit,
      TEST_FOLDERPATH, TEST_J_IUNIT_PATH, queries)
    intents = import_intents(TestJaIntent, TEST_FOLDERPATH, TEST_J_INTENT_PATH,
      TEST_EVAL_FOLDERPATH, TEST_J_PROBABILITY_PATH, queries)
    judges = import_judges(TestJaJudge, TEST_EVAL_FOLDERPATH, TEST_J_IMPORTANCE_PATH,
      queries, iunits, intents)
    update_test_iunit_weight(iunits, intents, judges)

    queries = import_query(TestEnQuery, TEST_FOLDERPATH, TEST_E_QUERY_PATH)
    iunits = import_test_iunits(TestEnIunit,
      TEST_FOLDERPATH, TEST_E_IUNIT_PATH, queries)
    intents = import_intents(TestEnIntent, TEST_FOLDERPATH, TEST_E_INTENT_PATH,
      TEST_EVAL_FOLDERPATH, TEST_E_PROBABILITY_PATH, queries)
    judges = import_judges(TestEnJudge, TEST_EVAL_FOLDERPATH, TEST_E_IMPORTANCE_PATH,
      queries, iunits, intents)
    update_test_iunit_weight(iunits, intents, judges)
  end

  task :download_training_data => :environment do
    download_data(Settings.training_data_url, TRAINING_FILEPATH)
  end

  task :download_test_data => :environment do
    download_data(Settings.test_data_url, TEST_FILEPATH)
  end

end
