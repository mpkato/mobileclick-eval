require 'spec_helper'
require 'rails_helper'

describe 'SummaryTruncater' do
  let!(:test_en_queries) { [
    create(:test_en_query, :summarization, qid: 'MC2-E-0001'),
    create(:test_en_query, :summarization, qid: 'MC2-E-0002')
  ] }

  def get_eid(n)
    return (n.name == 'iunit' ? n[:uid] : n[:iid])
  end

  describe "#truncate" do
    let(:st) { SummaryTruncater.new(TestEnQuery, length) }
    let(:file) { fixture_file_upload("/runs/test_summarization_en.xml") }
    let(:summaries) { Summary.read(file)[1] }
    let(:summary) {st.truncate(summaries.find {|s| s.qid == qid})} 

    context "length = 4" do
      let(:length) { 4 }
      context "for MC2-E-0001 first" do
        let(:qid) { "MC2-E-0001" }
        subject(:eids) { summary.first.map {|n| get_eid(n)} }
        it { expect(eids).to match(
          ["MC2-E-0001-0001", "MC2-E-0001-0003"]) }
      end

      context "for MC2-E-0002 MC2-E-0002-INTENT0002" do
        let(:qid) { "MC2-E-0002" }
        let(:iid) { "MC2-E-0002-INTENT0002" }
        subject(:eids) { summary.seconds[iid].map {|n| get_eid(n)} }
        it { expect(eids).to match(
          ["MC2-E-0002-0009", "MC2-E-0002-0011"]) }
      end

      context "if trailed" do
        let(:qid) { "MC2-E-0001" }
        let(:factory) { TrailtextFactory.new(TestEnQuery) }
        let(:trailtexts) { factory.create(summary) }
        subject(:trailtext) { trailtexts.find{|tt| tt.iid == "MC2-E-0001-INTENT0001"} }
        it { expect(trailtext.elements.map {|e| e.eid}).to match(
          ["MC2-E-0001-0001", "MC2-E-0001-0003"]) }
      end
    end

    context "length = 10" do
      let(:length) { 10 }
      context "for MC2-E-0001 first" do
        let(:qid) { "MC2-E-0001" }
        subject(:eids) { summary.first.map {|n| get_eid(n)} }
        it { expect(eids).to match(
          ["MC2-E-0001-0001", "MC2-E-0001-0003", "MC2-E-0001-INTENT0001"]) }
      end

      context "for MC2-E-0002 MC2-E-0002-INTENT0002" do
        let(:qid) { "MC2-E-0002" }
        let(:iid) { "MC2-E-0002-INTENT0002" }
        subject(:eids) { summary.seconds[iid].map {|n| get_eid(n)} }
        it { expect(eids).to match(
          ["MC2-E-0002-0009", "MC2-E-0002-0011", "MC2-E-0002-0012"]) }
      end
    end

  end
end

