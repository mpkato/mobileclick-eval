class Trailtext
  attr_reader :qid, :iid, :probability, :elements
  def initialize(qid, iid, probability, elements)
    @qid = qid
    @iid = iid
    @probability = probability
    @elements = elements
  end
end
