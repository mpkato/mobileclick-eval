# -*- coding: utf-8 -*-
module Metric
  #= Qmeasure
  # 
  class Qmeasure
    #[qrels]
    # Qrelのハッシュ
    # [Qrel] => {doc_id: grade}
    def initialize(qrels)
      @qrels = qrels.clone
      @qrels.default = 0.0
    end

    #Qを計算
    #[systemlist]
    # Doc IDのリスト （順序=ランキング）
    def evaluate(systemlist)
      cbg = 0.0
      cig = 0.0
      cummurative = 0.0
      ideal_ranked_list = get_ideal_ranked_list
      ideal_ranked_list.each_with_index do |idoc_id, rank|
        # cig: cummurative ideal gain
        cig += ig(idoc_id)
        # gain
        g = gain(systemlist[rank])
        # cbg(r) = g(r) + cbg(r-1)
        cbg += bg(g) # note: 0 if gain == 0
        # cbg(r) / (cig(r) + rank)
        cummurative += cbg / (cig + (rank + 1)) if g > 0
      end
      result = num_rel > 0 ? cummurative / num_rel : 0.0
      return result
    end

    private
      # Gain
      #[doc_id]
      # Doc ID
      def gain(doc_id)
        return @qrels[doc_id] # as is
      end

      # bg
      # bg(r) = g(r) + 1 if g(r) > 0; otherwise 0
      # [g]
      # gain
      def bg(g)
        return g > 0 ? g + 1.0 : 0.0
      end

      # ig
      #[doc_id]
      # Doc ID
      def ig(doc_id)
        return gain(doc_id)
      end

      # ideal_ranked_list
      def get_ideal_ranked_list
        doc_ids = @qrels.keys
        # ideal ranked list (sort by gain)
        result = doc_ids.sort_by {|doc_id| -gain(doc_id)}
        return result
      end

      def num_rel
        return @qrels.values.select {|v| v > 0}.size
      end

  end
end


