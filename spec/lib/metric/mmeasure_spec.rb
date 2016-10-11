require 'spec_helper'
require 'rails_helper'

describe 'Mmeasure' do
  let(:umeasure) { Metric::Umeasure.new(20) }
  let(:metric) { Metric::Mmeasure.new(umeasure) }
  let(:score) { metric.evaluate(trailtexts) }
  let(:trailtext1) { Trailtext.new("1", "1", 0.6, [
    IunitElement.new("1", "XXXXX", 2.0),
    IunitElement.new("2", "XXXXX", 4.0),
    IunitElement.new("2", "XXXXX", 4.0),
    IunitElement.new("4", "XXXXX", 1.0)
  ])}
  let(:trailtext2) { Trailtext.new("1", "2", 0.4, [
    IunitElement.new("1", "XXXXX", 2.0),
    IunitElement.new("2", "XXXXX", 4.0),
    IntentElement.new("3", "XXXXX"),
    IunitElement.new("4", "XXXXX", 1.0)
  ])}
  let(:trailtexts) { [trailtext1, trailtext2] }

  it 'correctly computes M' do
    expect(score).to almost_eq(3.5, 5)
  end
end

