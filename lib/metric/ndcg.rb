# -*- coding: utf-8 -*-
module Metric
  #= nDCG
  # Microsoft version
  class Ndcg
    #[qrels]
    # Qrelのハッシュ
    # [Qrel] => {doc_id: grade}
    #[cutoff]
    # Cutoffパラメータ
    def initialize(qrels, cutoff)
      @qrels = qrels.clone
      @qrels.default = 0.0
      @cutoff = cutoff
    end

    #nDCGを計算
    #[systemlist]
    # Doc IDのリスト （順序=ランキング）
    def evaluate(systemlist)
      ndcg(systemlist)
    end

    #nDCGを計算
    #[systemlist]
    # Doc IDのリスト （順序=ランキング）
    def ndcg(systemlist)
      dcg_result = dcg(systemlist)
      idcg_result = idcg
      if idcg_result == 0
        return 0.0
      else
        return dcg_result / idcg_result
      end
    end

    #DCGを計算
    #[systemlist]
    # Doc IDのリスト （順序=ランキング）
    def dcg(systemlist)
      # cutoff
      systemlist = systemlist[0, @cutoff]

      # obtain gain list
      glist = systemlist.map {|doc_id| gain(doc_id)}

      # cumulation with discount by 1/log(r+1)
      result = 0.0
      glist.each_with_index do |g, idx|
        rank = idx + 1
        result += g / Math.log2(rank + 1)
      end

      return result
    end

    #nDCG*を計算
    def idcg
      doc_ids = @qrels.keys
      # ideal ranked list (sort by gain)
      ideal_ranked_list = doc_ids.sort_by {|doc_id| -gain(doc_id)}
      # compute DCG
      result = dcg(ideal_ranked_list)
      return result
    end

    private
      # Gain
      #[doc_id]
      # Doc ID
      def gain(doc_id)
        return @qrels[doc_id] # as is
      end

  end
end

