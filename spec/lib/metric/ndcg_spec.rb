require 'spec_helper'
require 'rails_helper'

describe 'Ndcg' do
  before :all do
    @qrels = {1 => 3, 2 => 3, 3 => 1, 4 => 1}
    @cutoff = 4
    @m = Metric::Ndcg.new(@qrels, @cutoff)
  end

  it 'correctly computes DCG (Sakai book, system X)' do
    score = @m.dcg([1, 5, 6, 3])
    expect(score).to almost_eq(3.431, 3)
  end

  it 'correctly computes nDCG (Sakai book, system X)' do
    score = @m.ndcg([1, 5, 6, 3])
    expect(score).to almost_eq(0.589, 3)
  end

  it 'correctly computes DCG (Sakai book, system Y)' do
    score = @m.dcg([3, 5, 6, 1])
    expect(score).to almost_eq(2.292, 3)
  end

  it 'correctly computes nDCG (Sakai book, system Y)' do
    score = @m.ndcg([3, 5, 6, 1])
    expect(score).to almost_eq(0.394, 3)
  end

  it 'correctly computes ideal DCG (Sakai book)' do
    score = @m.idcg
    expect(score).to almost_eq(5.823, 3)
  end
end

