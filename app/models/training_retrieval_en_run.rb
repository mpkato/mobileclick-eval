class TrainingRetrievalEnRun < RetrievalRun
  ORIGINAL_QUERY = TrainingEnQuery
  def self.model_name
    Run.model_name
  end
end

