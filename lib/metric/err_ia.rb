# -*- coding: utf-8 -*-
module Metric
  #= ERR-IA (ERR intent-aware)
  # O. Chapelle et al. Intent-based diversification of web search results:
  # Metrics and algorithms. Information Retrieval, Vol. 14, No. 6, pp. 572–592, 2011.
  class ErrIa
    #[subtopics]
    # Subtopicのリスト
    #[qrels]
    # Qrelのリスト
    #[cutoff]
    # Cutoffパラメータ
    #[max_grade]
    # 評価値の最大値
    def initialize(subtopics, qrels, cutoff, max_grade)
      raise ArgumentError.new("subtopics should not be empty") if subtopics.empty?

      # [Subtopic] => {topic_id: [Subtopic]}
      @subtopics = subtopics.group_by {|subtopic| subtopic.topic_id}

      # [Qrel] => {topic_id: [Qrel]}
      @qrels = qrels.group_by {|qrel| qrel.topic_id}

      @cutoff = cutoff
      @max_grade = max_grade
    end

    #ERR-IAを計算
    #[topic_id]
    # Topic ID
    #[systemlist]
    # ClueWebのIDのリスト （順序=ランキング）
    def evaluate(topic_id, systemlist)
      # obtain subtopics and qrels for the given topic_id
      subtopics = @subtopics[topic_id]
      # {topic_id: [Qrel]} => {subtopic_id: [Qrel]}
      qrels = @qrels[topic_id].group_by {|qrel| qrel.subtopic_id}

      # ERR-IA = \sum P(i|q)*ERR_i
      result = subtopics.sum do |subtopic|
        subtopic_qrels = qrels.include?(subtopic.id) ? qrels[subtopic.id] : []
        err = Metric::Err.new(subtopic_qrels, @cutoff, @max_grade)
        subtopic.normalized_prob * err.evaluate(topic_id, systemlist)
      end

      return result
    end
  end
end

