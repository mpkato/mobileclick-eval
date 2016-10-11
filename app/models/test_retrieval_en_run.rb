class TestRetrievalEnRun < RetrievalRun
  ORIGINAL_QUERY = TestEnQuery
  def self.model_name
    Run.model_name
  end
end

