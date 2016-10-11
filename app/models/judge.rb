class Judge < ActiveRecord::Base
  belongs_to :query
  belongs_to :intent
  belongs_to :iunit

  validates :qid, presence: true
  validates :iid, presence: true
  validates :uid, presence: true
  validates :query_id, presence: true
  validates :intent_id, presence: true
  validates :iunit_id, presence: true
  validates :importance, presence: true
end
