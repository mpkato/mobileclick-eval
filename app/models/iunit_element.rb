class IunitElement < Element
  def initialize(eid, content, importance)
    super(eid, content)
    @importance = importance
  end
end
