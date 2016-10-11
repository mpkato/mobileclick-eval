class TestSummarizationJaRun < SummarizationRun
  L_OF_U = Settings.l_of_u.ja
  LENGTH_LIMIT = Settings.length_limit.ja
  ORIGINAL_QUERY = TestJaQuery
  def self.model_name
    Run.model_name
  end
end

