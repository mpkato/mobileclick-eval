class SummarizationRun < Run
  METRICS = [
    ['M', lambda {|l| Metric::Mmeasure.new(Metric::Umeasure.new(l)) }]
  ]
  PRIMARY_METRIC = 'M'

  def compute_metrics
    result = {}
    factory = TrailtextFactory.new(self.class::ORIGINAL_QUERY)
    desc, summaries = read_summaries
    summaries = truncate(summaries, self.class::LENGTH_LIMIT)
    METRICS.each do |name, func|
      result[name] = {}
      m = func.call(self.class::L_OF_U)
      summaries.each do |summary|
        qid = summary.qid
        trailtexts = factory.create(summary)
        result[name][qid] = m.evaluate(trailtexts)
      end
    end
    return result
  end

  def run_file_content_validation
    begin
      desc, summaries = read_summaries
      if desc.empty?
        errors.add(:run_file, ": Description should not be blank")
      else
        self.description = desc
      end
      summary_validation(summaries)
    rescue SummaryError => ex
      errors.add(:run_file, ex.to_s)
    end
  end

  def read_summaries
    io = File.open(filepath)
    desc, result = Summary.read(io)
    return [desc, result]
  end

  private
    def summary_validation(summaries)
      queries = self.class::ORIGINAL_QUERY.includes(:iunits, intents: :judges).all
      # QID validation
      qid_validation(queries, summaries)
      # UID validation
      uid_validation(queries, summaries)
      # IID validation
      iid_validation(queries, summaries)
    end

    def qid_validation(queries, summaries)
      qid_counter = {}
      queries.each {|q| qid_counter[q.qid] = 0}
      summaries.each do |summary|
        qid = summary.qid
        # QID exists?
        unless qid_counter.include?(qid)
          errors.add(:run_file, ": QID #{qid} is invalid")
          next
        end
        qid_counter[qid] += 1
        # QID must appear only onece
        if qid_counter[qid] > 1
          errors.add(:run_file, ": QID #{qid} is duplicate")
        end
      end
      qid_counter.each do |qid, cnt|
        # QID exists?
        unless cnt > 0
          errors.add(:run_file, ": QID #{qid} was not found")
        end
      end
    end

    def uid_validation(queries, summaries)
      uid_set = Set.new()
      queries.each {|q| uid_set.merge(q.iunits.map(&:uid))}
      summaries.each do |summary|
        nodes = summary.first.clone
        summary.seconds.values.each {|second| nodes += second}
        nodes.select{|n| n.name == 'iunit'}.each do |node|
          uid = node[:uid]
          # UID valid?
          unless uid_set.include?(uid)
            errors.add(:run_file, ": UID #{uid} is invalid")
          end
        end
      end
    end

    def iid_validation(queries, summaries)
      original_iid_set = Set.new()
      queries.each {|q| original_iid_set.merge(q.intents.map(&:iid))}
      summaries.each do |summary|
        intent_nodes = summary.first.select {|n| n.name == 'link'}
        iid_set = Set.new(intent_nodes.map {|n| n[:iid]})
        iid_set.each do |iid|
          # IID valid?
          unless original_iid_set.include?(iid)
            errors.add(:run_file, ": IID #{iid} is invalid")
          else
            # Second layer exists?
            unless summary.seconds.include?(iid)
              errors.add(:run_file, ": Second layer for IID #{iid} does not exist")
            end
          end
        end
        summary.seconds.keys.each do |iid|
          # Link exists?
          unless iid_set.include?(iid)
            errors.add(:run_file, ": Link for IID #{iid} does not exist")
          end
        end
      end
    end

    def truncate(summaries, length)
      result = []
      st = SummaryTruncater.new(self.class::ORIGINAL_QUERY, length)
      summaries.each do |summary|
        result << st.truncate(summary)
      end
      return result
    end
end
