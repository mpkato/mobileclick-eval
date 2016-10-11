class Element
  attr_reader :eid, :content, :importance
  def initialize(eid, content)
    @eid = eid
    @content = content
    @importance = 0
  end

  def len
    if @_len.nil?
      @_len = get_length
    end
    return @_len
  end

  private
    def get_length
      return @content.remove_symbols.size
    end
end
