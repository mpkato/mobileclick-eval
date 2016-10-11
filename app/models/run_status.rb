class RunStatus < ActiveRecord::Base
  belongs_to :run
  enum status: [:error_found, :evaluated]
  serialize :results

  def set_score(metric)
    vals = results[metric].values
    self.score = vals.sum / vals.size.to_f
  end

end
