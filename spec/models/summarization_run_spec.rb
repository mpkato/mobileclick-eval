require 'rails_helper'

RSpec.describe SummarizationRun, type: :model do
  let!(:test_en_queries) { [
    create(:test_en_query, :summarization, qid: 'MC2-E-0001'),
    create(:test_en_query, :summarization, qid: 'MC2-E-0002')
  ] }

  describe "#create" do

    context "with valid file" do
      subject(:summarization_run) { build(:test_summarization_en_run) }
      it { expect(summarization_run).to be_valid }
    end

    context "with valid file with empty layers" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_empty.xml")) }
      it { expect(summarization_run).to be_valid }
    end

    context "with invalid file with no sysdesc" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_no_sysdesc.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to start_with("Error:") 
      }
    end

    context "with invalid file with invalid QID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_wrong_qid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("is invalid") 
      }
    end

    context "with invalid file with multiple QID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_multiple_qid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("is duplicate") 
      }
    end

    context "with invalid file with missing QID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_missing_qid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("was not found") 
      }
    end

    context "with invalid file with invalid UID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_wrong_uid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("is invalid") 
      }
    end

    context "with invalid file with invalid IID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_wrong_iid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("is invalid") 
      }
    end

    context "with invalid file with multiple IID" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_multiple_iid.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to start_with("contains multiple") 
      }
    end

    context "with invalid file with missing IID in the first layer" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_missing_iid_in_first.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("not exist") 
      }
    end

    context "with invalid file with missing IID in the second layer" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_with_missing_iid_in_second.xml")) }
      it { 
        expect(summarization_run).to be_invalid 
        expect(summarization_run.errors[:run_file].first).to end_with("not exist") 
      }
    end

  end

  describe "#read_summaries" do
    context "with valid file" do
      subject(:desc) { create(:test_summarization_en_run).read_summaries[0] }
      subject(:summaries) { create(:test_summarization_en_run).read_summaries[1] }
      it { expect(desc).to eq("Organizers' Baseline") }
      it { expect(summaries.first).to be_a(Summary) }
      it { expect(summaries.size).to eq(2) }
    end

    context "with invalid file" do
      subject(:summarization_run) { build(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_no_sysdesc.xml")) }
      it { expect{summarization_run.read_summaries}.to raise_error(SummaryError) }
    end
  end

  describe "#compute_metrics" do
    context "with test_summarization_en.xml" do
      subject(:summarization_run_scores) { create(:test_summarization_en_run).compute_metrics }
      it { expect(summarization_run_scores["M"]["MC2-E-0001"]).to almost_eq(16.13857143, 6) }
      it { expect(summarization_run_scores["M"]["MC2-E-0002"]).to almost_eq(17.04928571, 6) }
    end

    context "with test_summarization_en_empty.xml" do
      subject(:summarization_run_scores) { create(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_empty.xml")).compute_metrics }
      it { expect(summarization_run_scores["M"]["MC2-E-0001"]).to almost_eq(0, 6) }
      it { expect(summarization_run_scores["M"]["MC2-E-0002"]).to almost_eq(0, 6) }
    end

    context "with test_summarization_en_2.xml" do
      subject(:summarization_run_scores) { create(:test_summarization_en_run,
        filepath: fixture_file("/runs/test_summarization_en_2.xml")).compute_metrics }
      <<EOS
      it { p ((
           5*0.1+6*0.2+7*0.3+8*0.4) * (1 - 2/840.0)\
        + (4*0.1+5*0.2+6*0.3+7*0.4) * (1 - 4/840.0)\
        + (      4*0.2+5*0.3+6*0.4) * (1 - 11/840.0) + 0.1 * 3 * (1 - 15/840.0)\
        + 0.1 * (1 * (1 - 11/840.0) + 2 * (1 - 13/840.0))
        )}
      it { p ((
           5*0.1+6*0.2+7*0.3+8*0.4) * (1 - 2/840.0)\
        + (3*0.1+4*0.2+5*0.3+6*0.4) * (1 - 4/840.0)\
        + (4*0.1+5*0.2+6*0.3+7*0.4) * (1 - 6/840.0)\
        + 0.1 * 1 * (1 - 13/840.0)\
        + 0.2 * 2 * (1 - 18/840.0)
        )}
EOS
      it { expect(summarization_run_scores["M"]["MC2-E-0001"]).to almost_eq(18.183452380952385, 6) }
      it { expect(summarization_run_scores["M"]["MC2-E-0002"]).to almost_eq(18.406547619047615, 6) }
    end
  end

end

