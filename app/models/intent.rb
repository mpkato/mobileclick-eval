class Intent < ActiveRecord::Base
  belongs_to :query
  has_many :judges
  validates :qid, presence: true
  validates :iid, presence: true
  validates :query_id, presence: true
  validates :content, presence: true
  validates :probability, presence: true
end
