class Iunit < ActiveRecord::Base
  belongs_to :query
  validates :qid, presence: true
  validates :uid, presence: true
  validates :query_id, presence: true
  validates :content, presence: true
  validates :importance, presence: true
end
