class TestSummarizationEnRun < SummarizationRun
  L_OF_U = Settings.l_of_u.en
  LENGTH_LIMIT = Settings.length_limit.en
  ORIGINAL_QUERY = TestEnQuery
  def self.model_name
    Run.model_name
  end
end
