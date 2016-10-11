# -*- coding: utf-8 -*-
module Metric
  #= D#-measure
  # Sakai and Song: Evaluating Diversified Search Results Using Per-intent Graded
  # Relevance, SIGIR 2011.
  class DSharpMeasure
    #[subtopics]
    # Subtopicのリスト
    #[qrels]
    # Qrelのリスト
    #[cutoff]
    # Cutoffパラメータ
    #[gamma]
    # parameter of D# (default: 0.5)
    def initialize(subtopics, qrels, cutoff, gamma=0.5)
      @d = Metric::DMeasure.new(subtopics, qrels, cutoff)
      @i = Metric::Irec.new(subtopics, qrels, cutoff)
      @gamma = gamma
    end

    #D#-nDCGを計算
		#[topic_id]
		# Topic ID
    #[systemlist]
    # ClueWebのリスト （順序=ランキング）
    def evaluate(topic_id, systemlist)
		  d_result = @d.evaluate(topic_id, systemlist) # D-nDCG
      i_result = @i.evaluate(topic_id, systemlist) # I-rec
      result = @gamma * i_result + (1.0 - @gamma) * d_result
      return result
    end

  end
end
