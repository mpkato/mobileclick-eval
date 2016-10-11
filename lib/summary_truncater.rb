class SummaryTruncater
  def initialize(qcls, length)
    queries = qcls.includes(:iunits, :intents).all
    @iunits = Hash[*(queries.map {|q| [q.qid, q.iunits.index_by(&:uid)]}.flatten)]
    @intents = Hash[*(queries.map {|q| [q.qid, q.intents.index_by(&:iid)]}.flatten)]
    @length = length
  end

  def truncate(summary)
    qid = summary.qid
    first = truncate_layer(qid, summary.first)
    seconds = {}
    summary.seconds.keys.each do |iid|
      seconds[iid] = truncate_layer(qid, summary.seconds[iid])
    end
    return Summary.new(summary.sysdesc, qid, first, seconds)
  end

  private
    def truncate_layer(qid, nodes)
      result = []
      total_length = 0
      nodes.each do |node|
        total_length += node_length(qid, node)
        break if total_length > @length
        result << node
      end
      return result
    end

    def node_length(qid, node)
      case node.name
      when 'iunit'
        uid = node[:uid]
        content = @iunits[qid][uid].content
        return Element.new(uid, content).len
      when 'link'
        iid = node[:iid]
        content = @intents[qid][iid].content
        return Element.new(iid, content).len
      end
    end

end
