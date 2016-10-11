require 'spec_helper'
require 'rails_helper'

describe 'Umeasure' do
  let(:metric) { Metric::Umeasure.new(20) }
  let(:score) { metric.evaluate(systemlist) }

  context "with duplicate elements" do
    let(:systemlist) {[
      IunitElement.new("1", "XXXXX", 2.0),
      IunitElement.new("2", "XXXXX", 4.0),
      IunitElement.new("2", "XXXXX", 4.0),
      IunitElement.new("4", "XXXXX", 1.0)
    ]}
    it 'correctly computes U' do
      expect(score).to almost_eq(3.5, 5)
    end
  end

  context "with intent elements" do
    let(:systemlist) {[
      IunitElement.new("1", "XXXXX", 2.0),
      IunitElement.new("2", "XXXXX", 4.0),
      IntentElement.new("3", "XXXXX"),
      IunitElement.new("4", "XXXXX", 1.0)
    ]}
    it 'correctly computes U' do
      expect(score).to almost_eq(3.5, 5)
    end
  end

end
