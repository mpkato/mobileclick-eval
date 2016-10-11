class TrainingRetrievalJaRun < RetrievalRun
  ORIGINAL_QUERY = TrainingJaQuery
  def self.model_name
    Run.model_name
  end
end
