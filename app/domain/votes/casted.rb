module Votes
  class Casted < RubyEventStore::Event
    SCHEMA = {
      event_id: Integer,
      user_id: String,
      old_vote_type: String,
      vote_type: String
    }.freeze
  end
end
