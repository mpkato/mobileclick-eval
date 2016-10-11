# -*- coding: utf-8 -*-
module Metric
  #= Mmeasure
  #
  class Mmeasure
    #[u]
    # Umeasure
    def initialize(u)
      @u = u
    end

    #Mを計算
    #[trailtexts]
    # a list of Trailtext
    def evaluate(trailtexts)
      return trailtexts.map {|tt|
        tt.probability * @u.evaluate(tt.elements)}.sum
    end

  end
end
