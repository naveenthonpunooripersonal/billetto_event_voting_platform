class Vote < ApplicationRecord
  belongs_to :event

  VOTE_TYPES = {
    "like" => "like",
    "dislike" => "dislike"
  }.freeze

  validates :user_id, presence: true

  validates :vote_type, inclusion: { in: VOTE_TYPES.keys }
end
