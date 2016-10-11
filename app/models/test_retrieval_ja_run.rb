class TestRetrievalJaRun < RetrievalRun
  ORIGINAL_QUERY = TestJaQuery
  def self.model_name
    Run.model_name
  end
end

