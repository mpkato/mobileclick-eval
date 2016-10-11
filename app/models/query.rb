class Query < ActiveRecord::Base
  has_many :iunits
  has_many :intents
  has_many :judges
  validates :qid, presence: true
  validates :content, presence: true
end
