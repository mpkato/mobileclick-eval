class Run < ActiveRecord::Base
  belongs_to :user
  has_one :run_status, dependent: :destroy

  attr_accessor :filepath

  enum runtype: [
    # Training
    :training_retrieval_en,
    :training_retrieval_ja,
    # Test
    :test_retrieval_en,
    :test_retrieval_ja,
    :test_summarization_en,
    :test_summarization_ja
  ]

  # human readable runtype labels
  RUNTYPE_LABELS = {
    # Training
    training_retrieval_en: 'English iUnit Ranking (Training)',
    training_retrieval_ja: 'Japanese iUnit Ranking (Training)',
    # Test
    test_retrieval_en: 'English iUnit Ranking (Test)',
    test_retrieval_ja: 'Japanese iUnit Ranking (Test)',
    test_summarization_en: 'English iUnit Summarization (Test)',
    test_summarization_ja: 'Japanese iUnit Summarization (Test)'
  }

  # help messages
  RUNTYPE_HELPS = {
    # Training
    training_retrieval_en: <<EOS,
Please generate an iUnit ranking run for a list of English queries in the training data.
EOS
    training_retrieval_ja: <<EOS,
Please generate an iUnit ranking run for a list of Japanese queries in the training data.
EOS
    # Test
    test_retrieval_en: <<EOS,
Please generate an iUnit ranking run for a list of English queries in the test data.
EOS
    test_retrieval_ja: <<EOS,
Please generate an iUnit ranking run for a list of Japanese queries in the test data.
EOS
    test_summarization_en: <<EOS,
Please generate an iUnit summarization run for a list of English queries in the test data.
EOS
    test_summarization_ja: <<EOS
Please generate an iUnit summarization run for a list of Japanese queries in the test data.
EOS
  }

  # validation
  validates :runtype, presence: true
  validates :filepath, presence: true
  validate :run_file_validation, on: :create

  def self.runtype_options
    self.runtypes.collect {|rt| [RUNTYPE_LABELS[rt[0].to_sym], rt[0]]}
  end

  # run file validation
  def run_file_validation
    unless filepath.nil?
      run_file_content_validation
    end
  end

  def evaluate
    results = compute_metrics
  end

  def self.new_run_instance(params)
    if not params[:runtype].nil? and not params[:runtype].empty?
      (params[:runtype].to_s.camelcase + "Run").constantize.new(params)
    else
      self.new(params)
    end
  end

  def run_file_content_validation
    # to be overwritten
  end

end
