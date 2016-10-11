require 'rails_helper'

RSpec.describe Element, type: :model do
  let(:element) { Element.new(eid, content) }
  let(:eid) { '1' }
  describe "#len" do
    subject(:len) { element.len }
    context do
      let(:content) { "- This is a test sentence!! -" }
      it { expect(len).to eq(19) }
    end
    context do
      let(:content) { "ー　これは『日本語』のテストです！　ー" }
      it { expect(len).to eq(12) }
    end
  end
end

