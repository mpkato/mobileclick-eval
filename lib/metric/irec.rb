# coding: utf-8

module Metric
  class Irec
    def initialize(subtopics, qrels, cutoff)
      # [Subtopic] => {topic_id: [Subtopic]}
      @subtopics = subtopics.group_by {|subtopic| subtopic.topic_id}
      # [Qrel] => {topic_id: {clue_web_id: [subtopic_ids]}}
      @qrels = Hash.new {|h1, k1| h1[k1] = Hash.new {|h2, k2| h2[k2] = []}}
      qrels.each do |qrel|
        @qrels[qrel.topic_id][qrel.clue_web_id] << qrel.subtopic_id
      end

      @cutoff = cutoff
    end

    def evaluate(topic_id, systemlist)
      systemlist = systemlist[0, @cutoff]
      system_subtopics = systemlist.map { |doc_id| @qrels[topic_id][doc_id] }.flatten.uniq
      system_subtopics.size.to_f / @subtopics[topic_id].size
    end
  end
end
