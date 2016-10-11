require 'rails_helper'

RSpec.describe RetrievalRun, type: :model do
  let!(:training_en_queries) { [
    create(:training_en_query, qid: '1C2-E-0001'),
    create(:training_en_query, qid: '1C2-E-0002')
  ] }

  let!(:test_en_queries) { [
    create(:test_en_query, qid: 'MC2-E-0001'),
    create(:test_en_query, qid: 'MC2-E-0002')
  ] }

  describe "#create" do

    context "for training data" do

      context "with valid file" do
        subject(:retrieval_run) { build(:training_retrieval_en_run) }
        it { expect(retrieval_run).to be_valid }
      end

      context "with valid file including blanks" do
        subject(:retrieval_run) { build(:training_retrieval_en_run,
          filepath: fixture_file("/runs/training_retrieval_en_blank.tsv")) }
        it { expect(retrieval_run).to be_valid }
      end

      context "with valid file when empty QID exists" do
        subject(:retrieval_run) { build(:training_retrieval_en_run) }
        let!(:extra_test_en_query) {
          create(:training_en_query_without_iunits, qid: '1C2-E-0003')
        }
        it "is valid" do
          expect(retrieval_run).to be_valid
        end
        it "has results for 1C2-E-0003" do
          res = retrieval_run.evaluate
          expect(res["Q"]).to have_key("1C2-E-0003")
          expect(res["Q"]["1C2-E-0003"]).to eq(0.0)
        end
      end

      context "with valid file of different encoding" do
        subject(:retrieval_run) { build(:training_retrieval_en_run,
          filepath: fixture_file("/runs/training_retrieval_en_#{enc}.tsv")) }

        context "win" do
          let(:enc) { "win" }
          it { expect(retrieval_run).to be_valid }
        end

        context "mac" do
          let(:enc) { "mac" }
          it { expect(retrieval_run).to be_valid }
        end
      end

      context "with valid file with whitespaces" do
        subject(:retrieval_run) { build(:training_retrieval_en_run,
          filepath: fixture_file("/runs/training_retrieval_en_whitespaces.tsv")) }
        it { expect(retrieval_run).to be_valid }
      end

      context "with invalid file without desc" do
        subject(:retrieval_run) { build(:training_retrieval_en_run,
          filepath: fixture_file("/runs/training_retrieval_en_without_desc.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("system description line")
        }
      end

      context "with invalid file with wrong rows" do
        subject(:retrieval_run) { build(:training_retrieval_en_run,
          filepath: fixture_file("/runs/training_retrieval_en_with_wrong_rows.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file]).to all(end_with("fields"))
        }
      end

      context "with invalid file with wrong importance" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_wrong_importance.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file]).to all(end_with("[score]"))
        }
      end

      context "with invalid file with a missing iUnit" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_lack_iunit.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("was not found")
        }
      end

      context "with invalid file with duplicate iUnits" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_duplication.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("multiple times")
        }
      end

      context "with invalid file with a missing query" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_lack_query.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("were not found")
        }
      end

      context "with invalid file with a wrong QID" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_wrong_qid.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("is invalid")
        }
      end

      context "with invalid file with a wrong UID" do
        subject(:retrieval_run) { build(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_with_wrong_uid.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("is invalid")
        }
      end

    end

    context "for test data" do

      context "with valid file" do
        subject(:retrieval_run) { build(:test_retrieval_en_run) }
        it { expect(retrieval_run).to be_valid }
      end

      context "with invalid file with a missing iUnit" do
        subject(:retrieval_run) { build(:test_retrieval_en_run, 
          filepath: fixture_file("/runs/test_retrieval_en_with_lack_iunit.tsv")) }
        it {
          expect(retrieval_run).to be_invalid
          expect(retrieval_run.errors).to have_key(:run_file)
          expect(retrieval_run.errors[:run_file].first).to end_with("was not found")
        }
      end
    end

  end

  describe "#read_run_file" do
    context "with valid file" do
      subject(:retrieval_run) { create(:training_retrieval_en_run) }
      it { expect(retrieval_run.read_run_file.first).to be_a_new(Iunit) }
      it { expect(retrieval_run.read_run_file.map {|i| i.qid}).to all(be_a(String)) }
    end

    context "with valid file including blanks" do
      subject(:retrieval_run) { create(:training_retrieval_en_run, 
        filepath: fixture_file("/runs/training_retrieval_en_blank.tsv")) }
      it { expect(retrieval_run.read_run_file.map {|i| i.qid}).to all(be_a(String)) }
      it { expect(retrieval_run.read_run_file.map {|i| i.uid}).to all(be_a(String)) }
      it { expect(retrieval_run.read_run_file.map {|i| i.importance}).to all(be_a(Float)) }
    end
  end

  describe "#read_run_file_per_qid" do
    subject(:retrieval_run_file) {
      create(:training_retrieval_en_run).read_run_file_per_qid }
    it { expect(retrieval_run_file.size).to eq(2) }
    ["1C2-E-0001", "1C2-E-0002"].each do |qid|
      it { expect(retrieval_run_file).to have_key(qid) }
      it { expect(retrieval_run_file[qid].size).to eq(3) }
      3.times do |n|
        it { expect(retrieval_run_file[qid][n].uid).to eq("#{qid}-000#{n+1}") }
      end
    end
  end

  describe "#compute_metrics" do
    
    context "for training data" do
      subject(:retrieval_run_scores) {
        create(:training_retrieval_en_run, 
          filepath: fixture_file("/runs/training_retrieval_en_ranking.tsv")
          ).compute_metrics }
      let(:qrels) { Hash[TrainingEnIunit.where(qid: "1C2-E-0001")
        .map {|i| [i.uid, i.importance]}] }
      let(:score) { Metric::Qmeasure.new(qrels).evaluate(
        [2, 3, 1].map {|n| "1C2-E-0001-000#{n}"}) }

      it { expect(retrieval_run_scores).to have_key("Q") }
      ["1C2-E-0001", "1C2-E-0002"].each do |qid|
        it { expect(retrieval_run_scores["Q"]).to have_key(qid) }
        it { expect(retrieval_run_scores["Q"][qid]).to eq(score) }
      end
    end

    context "for test data" do
      subject(:retrieval_run_scores) { create(:test_retrieval_en_run).compute_metrics }
      it { expect(retrieval_run_scores["Q"]["MC2-E-0001"]).to almost_eq(0.58042328, 6) }
      it { expect(retrieval_run_scores["Q"]["MC2-E-0002"]).to almost_eq(1.0, 6) }
      it { expect(retrieval_run_scores["nDCG@3"]["MC2-E-0001"]).to almost_eq(0.342498503, 6) }
      it { expect(retrieval_run_scores["nDCG@3"]["MC2-E-0002"]).to almost_eq(1.0, 6) }
    end

  end

end
