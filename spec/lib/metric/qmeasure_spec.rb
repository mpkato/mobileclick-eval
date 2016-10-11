require 'spec_helper'
require 'rails_helper'

describe 'Qmeasure' do
  before :all do
    @qrels = {1 => 3, 2 => 3, 3 => 1, 4 => 1}
    @m = Metric::Qmeasure.new(@qrels)
  end

  it 'correctly computes Q (Sakai book, system X)' do
    score = @m.evaluate([1, 5, 6, 3])
    expect(score).to almost_eq(0.375, 3)
  end

  it 'correctly computes Q (Sakai book, system Y)' do
    score = @m.evaluate([3, 5, 6, 1])
    expect(score).to almost_eq(0.250, 3)
  end

  it 'returns 0.0 if no relevant items' do
    m = Metric::Qmeasure.new({1 => 0, 2 => 0, 3 => 0, 4 => 0})
    score = m.evaluate([3, 5, 6, 1])
    expect(score).to almost_eq(0.0, 3)
  end
end
