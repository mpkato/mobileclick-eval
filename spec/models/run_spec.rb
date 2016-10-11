require 'rails_helper'

RSpec.describe Run, type: :model do
  let!(:training_en_queries) { [
    create(:training_en_query, qid: '1C2-E-0001'),
    create(:training_en_query, qid: '1C2-E-0002')
  ] }

  let!(:test_en_queries) { [
    create(:test_en_query, qid: 'MC2-E-0001'),
    create(:test_en_query, qid: 'MC2-E-0002')
  ] }

  describe "#run_file_validation" do

    context "with valid file" do
      subject(:retrieval_run) { build(:training_retrieval_en_run) }
      it { expect(retrieval_run).to be_valid }
    end

    context "with invalid file" do
      subject(:retrieval_run) { build(:training_retrieval_en_run,
        filepath: fixture_file("/runs/training_retrieval_en_without_desc.tsv")) }
      it { expect(retrieval_run).to be_invalid }
    end

  end

  describe "#evaluate" do
    subject(:retrieval_run) { create(:training_retrieval_en_run) }

    context "in valid situation" do
      it {
        expect(retrieval_run.evaluate).to be_truthy
        expect(retrieval_run.evaluate).to be_a(Hash)
        expect(retrieval_run.evaluate["nDCG@3"]["1C2-E-0001"]).to be > 0
      }
    end

  end

  describe "#new_run_instance" do
    [TrainingRetrievalEnRun, TrainingRetrievalJaRun,
    TestRetrievalEnRun, TestRetrievalJaRun,
    TestSummarizationEnRun, TestSummarizationJaRun].each do |cls|
      context cls do
        let(:runtype) { cls.to_s[0..-4].underscore.to_sym }
        let(:attributes) { attributes_for(:training_retrieval_en_run, 
          runtype: runtype) }
        subject(:run) { Run.new_run_instance(attributes) }
        it { expect(run).to be_a_new(cls) }
      end
    end
  end

end
