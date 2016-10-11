class HtmlSummaryFactory

  # @queries = {qid: query}
  # @iunits = {qid: {uid: iunit}}
  # @intents = {qid: {iid: intent}}
  def initialize(qcls, length)
    @queries = qcls.includes(:iunits, :intents).all.index_by(&:qid)
    @iunits = Hash[*(@queries.values.map {|q| [q.qid, q.iunits.index_by(&:uid)]}.flatten)]
    @intents = Hash[*(@queries.values.map {|q| [q.qid, q.intents.index_by(&:iid)]}.flatten)]
    @truncater = SummaryTruncater.new(qcls, length)
  end

  def create(summary)
    summary = @truncater.truncate(summary)
    qid = summary.qid
    first = summary.first.map {|elem| parse_elem(qid, elem)}
    seconds = {}
    summary.seconds.keys.each do |iid|
      seconds[iid] = summary.seconds[iid].map {|elem| parse_elem(qid, elem)}
    end
    result = convert(summary.object_id, first, seconds)
    return result
  end

  private

    def convert(run_id, first, seconds)
      result = []
      first.each do |elem|
        if Iunit === elem
          result << iunit_html(elem)
        else
          result << intent_html(run_id, elem)
          result += second_html(run_id, elem.iid, seconds[elem.iid])
        end
      end
      return result.join("\n")
    end

    def iunit_html(elem)
      return "<span class='iunit'>#{elem.content.capitalize}</span>"
    end

    def intent_html(run_id, elem)
      return "<div class='intent'><a data-toggle='collapse' "\
        + "href='##{run_id}-#{elem.iid}' aria-expanded='false' "\
        + "aria-controls='#{run_id}-#{elem.iid}'>#{elem.content}</a></div>"
    end

    def second_html(run_id, iid, elems)
      result = []
      result << "<div class='second_layer collapse' id='#{run_id}-#{iid}'>"
      result += elems.map {|elem| "  " + iunit_html(elem)}
      result << "</div>"
      return result
    end

    def parse_elem(qid, elem)
      if elem.name == 'iunit'
        return @iunits[qid][elem['uid']]
      elsif elem.name == 'link'
        return @intents[qid][elem['iid']]
      else
        raise "Invalid Summarization Run: #{elem}"
      end
    end

end
