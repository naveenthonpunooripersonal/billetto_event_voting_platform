class Event < ApplicationRecord
  validates :billetto_event_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :event_url, presence: true
  validates :start_date, presence: true


  has_many :votes, dependent: :destroy
  has_one :event_vote_count
end
