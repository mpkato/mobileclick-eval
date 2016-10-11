class RetrievalRun < Run
  METRICS = [
    ['nDCG@3', lambda{|qrels| Metric::Ndcg.new(qrels, 3)}],
    ['nDCG@5', lambda{|qrels| Metric::Ndcg.new(qrels, 5)}],
    ['nDCG@10', lambda{|qrels| Metric::Ndcg.new(qrels, 10)}],
    ['nDCG@20', lambda{|qrels| Metric::Ndcg.new(qrels, 20)}],
    ['Q', lambda{|qrels| Metric::Qmeasure.new(qrels)}],
  ]
  PRIMARY_METRIC = 'Q'

  # nDCG@3, 5, 10, 20 and Q
  def compute_metrics
    result = {}
    submitted_iunits = read_run_file_per_qid
    original_iunits = get_original_iunits.group_by(&:qid)
    qids = self.class::ORIGINAL_QUERY.pluck(:qid)
    METRICS.each do |name, func|
      result[name] = {}
      qids.each {|qid| result[name][qid] = 0.0} # init for empty query
      original_iunits.each do |qid, oiunits|
        qrels = Hash[oiunits.map {|i| [i.uid, i.importance]}]
        systemlist = submitted_iunits[qid].map {|i| i.uid}
        m = func.call(qrels)
        result[name][qid] = m.evaluate(systemlist)
      end
    end
    return result
  end

  def run_file_content_validation
    begin
      run_file_file_format_validation
      unless errors.has_key?(:run_file)
        run_file_iunit_validation
      end
    rescue CSV::MalformedCSVError => ex
      errors.add(:run_file, " is an invalid file")
    end
  end

  def run_file_iunit_validation
    submitted_iunits = read_run_file_per_qid
    original_iunits = get_original_iunits.group_by(&:qid)
    # QID valid?
    qid_validation(submitted_iunits, original_iunits)

    original_iunits.each do |qid, oiunits|
      # QID exists?
      unless submitted_iunits.has_key?(qid)
        errors.add(:run_file, ": Results for #{qid} were not found")
      else
        siunits = submitted_iunits[qid].group_by(&:uid)
        # UID validation
        uid_validation(siunits, oiunits)
      end
    end
  end

  def qid_validation(submitted_iunits, original_iunits)
    submitted_iunits.keys.each do |qid|
      unless original_iunits.has_key?(qid)
        errors.add(:run_file, ": QID #{qid} is invalid")
      end
    end
  end

  def uid_validation(siunits, oiunits)
    # UID valid?
    valid_uids = Set.new(oiunits.map(&:uid))
    siunits.keys.each do |uid|
      unless valid_uids.include?(uid)
        errors.add(:run_file, ": UID #{uid} is invalid")
      end
    end

    oiunits.each do |i|
      # UID exists?
      unless siunits.has_key?(i.uid)
        errors.add(:run_file, ": iUnit #{i.uid} was not found")
      else
        # duplicate UID?
        if siunits[i.uid].size > 1
          errors.add(:run_file, ": iUnit #{i.uid} appears multiple times")
        end
      end
    end
  end

  def run_file_file_format_validation
    file_content = File.open(filepath).read
    CSV.new(file_content, col_sep: "\t").each_with_index do |row, idx|
      if idx == 0
        # desc line
        if row.size != 1
          errors.add(:run_file, 'must start with a system description line')
        end

        # set the description
        self.description = row[0]
        next
      end

      # filed num
      if row.size != 0 and row.size != 3
        errors.add(:run_file, "line ##{idx+1} contains too many/few fields")
      end

      # when the field num is correct
      if row.size == 3
        # score is float?
        begin
          val = Float(row[2])
        rescue
          errors.add(:run_file, "line ##{idx+1} contains invalid [score]")
        end
      end
    end
  end

  def read_run_file
    result = []
    file_content = File.open(filepath).read
    CSV.new(file_content, col_sep: "\t").each_with_index do |row, idx|
      if row.size == 3
        qid, uid, importance = row.map(&:strip)
        i = Iunit.new(qid: qid, uid: uid, importance: importance.to_f)
        result << i
      end
    end
    return result
  end

  def read_run_file_per_qid
    result = {}
    iunits = read_run_file
    iunits.each do |iunit|
      result[iunit.qid] ||= []
      result[iunit.qid] << iunit
    end
    return result
  end

  private
    def get_original_iunits
      result = []
      self.class::ORIGINAL_QUERY.includes(:iunits).all.each {|q|
        result += q.iunits.to_a}
      return result
    end

end
