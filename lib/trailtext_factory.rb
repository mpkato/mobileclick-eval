class TrailtextFactory

  # @queries = {qid: query}
  # @iunits = {qid: {uid: iunit}}
  # @intents = {qid: {iid: intent}}
  # @judges = {qid: {iid: {uid: judge}}}
  def initialize(qcls)
    @queries = qcls.includes(:iunits, intents: :judges).all.index_by(&:qid)
    @iunits = Hash[*(@queries.values.map {|q| [q.qid, q.iunits.index_by(&:uid)]}.flatten)]
    @intents = Hash[*(@queries.values.map {|q| [q.qid, q.intents.index_by(&:iid)]}.flatten)]
    @judges = {}
    @queries.values.each do |query|
      @judges[query.qid] = {}
      query.intents.each do |intent|
        @judges[query.qid][intent.iid] = {}
        intent.judges.each do |judge|
          @judges[query.qid][intent.iid][judge.uid] = judge
        end
      end
    end
  end

  def create(summary)
    qid = summary.qid
    query = @queries[qid]
    result = []
    query.intents.each do |intent|
      iid = intent.iid
      trailed_text = trail(iid, summary)
      result << Trailtext.new(qid, iid, intent.probability, trailed_text)
    end
    return result
  end

  private
    def trail(iid, summary)
      qid = summary.qid
      result = []
      first_elements = summary.first.map {|node| trans(qid, iid, node)}
      first_elements.each do |elem|
        result << elem
        if IntentElement === elem and elem.eid == iid
          result += summary.seconds[iid].map {|node| trans(qid, iid, node)}
        end
      end
      return result
    end

    def trans(qid, iid, node)
      case node.name
      when 'iunit'
        uid = node[:uid]
        content = @iunits[qid][uid].content
        importance = @judges[qid][iid][uid].importance
        return IunitElement.new(uid, content, importance)
      when 'link'
        iid = node[:iid]
        content = @intents[qid][iid].content
        return IntentElement.new(iid, content)
      end
    end
end
