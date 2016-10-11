require 'spec_helper'
require 'rails_helper'

describe 'TrailtextFactory' do
  let(:file) { fixture_file_upload("/runs/test_summarization_en.xml") }
  let(:summaries) { Summary.read(file)[1] }
  let(:factory) { TrailtextFactory.new(TestEnQuery) }
  let!(:queries) {[
    create(:test_en_query, :summarization, qid: 'MC2-E-0001'),
    create(:test_en_query, :summarization, qid: 'MC2-E-0002')
  ]}

  describe '#create' do
    let(:trailtext) { factory.create(summaries.find {|s| s.qid == qid})
      .find {|t| t.iid == iid} }
    let(:eids) { trailtext.elements.map {|e| e.eid} }

    it { expect(factory.create(summaries.first).size).to eq(5) }

    context 'with MC2-E-0001 for MC2-E-0001-INTENT0001' do
      let(:qid) { "MC2-E-0001" }
      let(:iid) { "MC2-E-0001-INTENT0001" }
      it { expect(eids).to match([
        "MC2-E-0001-0001", "MC2-E-0001-0003", 
        "MC2-E-0001-INTENT0001", 
        "MC2-E-0001-0011", "MC2-E-0001-0009",
        "MC2-E-0001-0004", "MC2-E-0001-INTENT0002"
        ]) }
      context "gives correct importance" do
        it { expect(trailtext.elements[0].importance).to eq(0) }
        it { expect(trailtext.elements[1].importance).to eq(2) }
        it { expect(trailtext.elements[2].importance).to eq(0) }
        it { expect(trailtext.elements[3].importance).to eq(10) }
        it { expect(trailtext.elements[4].importance).to eq(8) }
      end
    end
    context 'with MC2-E-0001 for MC2-E-0001-INTENT0002' do
      let(:qid) { "MC2-E-0001" }
      let(:iid) { "MC2-E-0001-INTENT0002" }
      it { expect(eids).to match([
        "MC2-E-0001-0001", "MC2-E-0001-0003",
        "MC2-E-0001-INTENT0001",
        "MC2-E-0001-0004", "MC2-E-0001-INTENT0002",
        "MC2-E-0001-0012", "MC2-E-0001-0011"
        ]) }
      context "gives correct importance" do
        it { expect(trailtext.elements[0].importance).to eq(1) }
        it { expect(trailtext.elements[1].importance).to eq(3) }
        it { expect(trailtext.elements[2].importance).to eq(0) }
        it { expect(trailtext.elements[3].importance).to eq(4) }
        it { expect(trailtext.elements[4].importance).to eq(0) }
        it { expect(trailtext.elements[5].importance).to eq(12) }
      end
    end
    context 'with MC2-E-0001 for MC2-E-0001-INTENT0003' do
      let(:qid) { "MC2-E-0001" }
      let(:iid) { "MC2-E-0001-INTENT0003" }
      it { expect(eids).to match([
        "MC2-E-0001-0001", "MC2-E-0001-0003", 
        "MC2-E-0001-INTENT0001", 
        "MC2-E-0001-0004", "MC2-E-0001-INTENT0002"
        ]) }
    end
    context 'with MC2-E-0002 for MC2-E-0002-INTENT0001' do
      let(:qid) { "MC2-E-0002" }
      let(:iid) { "MC2-E-0002-INTENT0001" }
      it { expect(eids).to match([
        "MC2-E-0002-0001", "MC2-E-0002-0003", 
        "MC2-E-0002-0004", "MC2-E-0002-INTENT0001", 
        "MC2-E-0002-0011", "MC2-E-0002-INTENT0002"
        ]) }
    end
    context 'with MC2-E-0002 for MC2-E-0002-INTENT0002' do
      let(:qid) { "MC2-E-0002" }
      let(:iid) { "MC2-E-0002-INTENT0002" }
      it { expect(eids).to match([
        "MC2-E-0002-0001", "MC2-E-0002-0003", 
        "MC2-E-0002-0004", "MC2-E-0002-INTENT0001", 
        "MC2-E-0002-INTENT0002", "MC2-E-0002-0009", 
        "MC2-E-0002-0011", "MC2-E-0002-0012"
        ]) }
    end
    context 'with MC2-E-0002 for MC2-E-0002-INTENT0003' do
      let(:qid) { "MC2-E-0002" }
      let(:iid) { "MC2-E-0002-INTENT0003" }
      it { expect(eids).to match([
        "MC2-E-0002-0001", "MC2-E-0002-0003", 
        "MC2-E-0002-0004", "MC2-E-0002-INTENT0001", 
        "MC2-E-0002-INTENT0002"
        ]) }
    end
  end

end
