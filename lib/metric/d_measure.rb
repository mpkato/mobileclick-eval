# -*- coding: utf-8 -*-
module Metric
  #= D-measure
  # Sakai and Song: Evaluating Diversified Search Results Using Per-intent Graded
  # Relevance, SIGIR 2011.
  class DMeasure
    #[subtopics]
    # Subtopicのリスト
    #[qrels]
    # Qrelのリスト
    #[cutoff]
    # Cutoffパラメータ
    def initialize(subtopics, qrels, cutoff)
      raise ArgumentError.new("subtopics should not be empty") if subtopics.empty?

      # [Subtopic] => {topic_id: [Subtopic]}
      @subtopics = subtopics.group_by {|subtopic| subtopic.topic_id}

      # [Qrel] => {topic_id: {clue_web_id: {subtopic_id: grade}}}
      @qrels = Hash.new {|h1, k1| h1[k1] = Hash.new {|h2, k2| h2[k2] = Hash.new(0.0)}}
      qrels.each do |qrel|
        @qrels[qrel.topic_id][qrel.clue_web_id][qrel.subtopic_id] = qrel.grade
      end

      @cutoff = cutoff
    end

    #D-nDCGを計算
    #[topic_id]
    # Topic ID
    #[systemlist]
    # ClueWebのIDのリスト （順序=ランキング）
    def evaluate(topic_id, systemlist)
      ndcg(topic_id, systemlist)
    end
    
    #D-nDCGを計算
    #[topic_id]
    # Topic ID
    #[systemlist]
    # ClueWebのIDのリスト （順序=ランキング）
    def ndcg(topic_id, systemlist)
      dcg_result = dcg(topic_id, systemlist)
      idcg_result = idcg(topic_id)
      if idcg_result == 0
        return 0.0
      else
        return dcg_result / idcg_result
      end
    end

    #D-DCGを計算
    #[topic_id]
    # Topic ID
    #[systemlist]
    # ClueWebのIDのリスト （順序=ランキング）
    def dcg(topic_id, systemlist)
      # obtain subtopics and qrels for the given topic_id
      subtopics = @subtopics[topic_id]
      qrels = @qrels[topic_id]

      # cutoff
      systemlist = systemlist[0, @cutoff]

      # obtain GG list
      gglist = systemlist.map {|doc_id| global_gain(subtopics, qrels, doc_id)}

      # cumulation with discount by 1/log(r+1)
      result = 0.0
      gglist.each_with_index do |gg, idx|
        rank = idx + 1
        result += gg / Math.log(rank + 1)
      end

      return result
    end

    #D-nDCG*を計算
    #[topic_id]
    # Topic ID
    def idcg(topic_id)
      # obtain subtopics and qrels for the given topic_id
      subtopics = @subtopics[topic_id]
      qrels = @qrels[topic_id]
      doc_ids = qrels.keys
      # ideal ranked list (sort by global gain)
      ideal_ranked_list = doc_ids.sort_by {|doc_id| -global_gain(subtopics, qrels, doc_id)}
      # compute DCG
      result = dcg(topic_id, ideal_ranked_list)
      return result
    end

    def ideal_ranked_list(topic_id)
      # obtain subtopics and qrels for the given topic_id
      subtopics = @subtopics[topic_id]
      qrels = @qrels[topic_id]
      doc_ids = qrels.keys
      # ideal ranked list (sort by global gain)
      result = doc_ids.sort_by {|doc_id| -global_gain(subtopics, qrels, doc_id)}[0, @cutoff]
      return result
    end

    private
      # Global gain (P(i|q)g_{i,d})
      #[subtopics]
      # 現トピックのSubtopicのリスト
      #[qrels]
      # 現トピックの{clue_web_id: {subtopic_id: grade}}
      #[doc]
      # ClueWebのID
      def global_gain(subtopics, qrels, doc_id)
        subtopics.sum {|subtopic| subtopic.normalized_prob * qrels[doc_id][subtopic.id]}
      end

  end
end

