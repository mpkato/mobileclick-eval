# -*- coding: utf-8 -*-
module Metric
  #= ERR (Expected Reciprocal Rank)
  # Chapelle et al. Expected Reciprocal Rank for Graded Relevance, CIKM 2009.
  # Qrelがsubtopicに対するrelevance gradeを持つ場合の実装.
  class Err
    #[qrels]
    # Qrelのリスト (ある単一のsubtopic_idしか含まないこと)
    #[cutoff]
    # Cutoffパラメータ
    #[max_grade]
    # 評価値の最大値
    def initialize(qrels, cutoff, max_grade)
      # Qrelのリストは高々1つのsubtopic_idしか含まないこと
      if qrels.map {|qrel| qrel.subtopic_id}.uniq.size > 1
        raise ArgumentError.new("there must be only a subtopic in qrels")
      end

      # [Qrel] => {topic_id: {clue_web_id: {subtopic_id: grade}}}
      @qrels = Hash.new {|h1, k1| h1[k1] = Hash.new(0.0)}
      qrels.each do |qrel|
        @qrels[qrel.topic_id][qrel.clue_web_id] = qrel.grade
      end

      @cutoff = cutoff
      @max_grade = max_grade
    end

    #ERRを計算
    #[topic_id]
    # Topic ID
    #[systemlist]
    # ClueWebのIDのリスト （順序=ランキング）
    def evaluate(topic_id, systemlist)
      # obtain qrels for the given topic_id
      qrels = @qrels[topic_id]

      # cutoff
      systemlist = systemlist[0, @cutoff]

      # cumulation with discount by (1/rank)\prod_{i=1}^{rank-1}(1-R_i)
      result = 0.0
      discount = 1.0
      systemlist.each_with_index do |doc_id, idx|
        rank = idx + 1
        grade = (2 ** qrels[doc_id] - 1.0) / 2 ** @max_grade
        result += discount * grade / rank
        discount *= (1.0 - grade)
      end

      return result
    end
  end
end
