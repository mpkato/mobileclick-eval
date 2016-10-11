class Summary
  include LibXML
  attr_reader :sysdesc, :qid, :first, :seconds

  def initialize(sysdesc, qid, first, seconds)
    @sysdesc = sysdesc
    @qid = qid
    @first = first
    @seconds = seconds
  end

  def inspect
    return self.to_s
  end

  def to_s
    return "#<#{self.class.name} @qid=\"#{@qid}\" "\
      + "@first=[#{@first.map {|i| i.name == 'iunit' ? "\"#{i[:uid]}\"" : "\"#{i[:iid]}\"" }.join(", ")}] "\
      + "@seconds={#{@seconds.keys.map {|iid| 
        "\"#{iid}\"=>[#{@seconds[iid].map {|i| "\"#{i[:uid]}\"" }.join(", ")}]" }.join(", ")}>"
  end

  def self.read(file)
    xml = read_xml(file)
    desc, result = parse_xml(xml)
    return [desc, result]
  end

  private
    def self.read_xml(file)
      xml = nil
      begin
        xml = XML::Document.io(file)
        dtd = XML::Dtd.new(Settings.dtd)
        result = xml.validate(dtd)
        raise SummaryError, "does not follow the DTD" unless result
      rescue XML::Error => ex
        raise SummaryError, ex.to_s
      end
      return xml
    end

    def self.parse_xml(xml)
      results = []
      sysdesc = xml.find_first('/results/sysdesc').content.strip
      xml.find('/results/result').each do |result|
        qid = result[:qid]
        first = result.find_first('first').find('iunit|link').to_a
        seconds = {}
        result.find('second').each do |second|
          iid = second[:iid]
          # Multiple second layers with the same IID?
          if seconds.include?(iid)
            raise SummaryError, "contains multiple second layers with IID #{iid}"
          end
          seconds[iid] = second.find('iunit').to_a
        end
        results << self.new(sysdesc, qid, first, seconds)
      end
      return [sysdesc, results]
    end

end
