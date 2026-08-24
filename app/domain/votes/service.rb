module Votes
    class Service
      def initialize(
        event_store: Rails.configuration.event_store
      )
        @event_store = event_store
      end
  
      def call(command)
        vote = Vote.find_by(
            event_id: command.event_id,
            user_id: command.user_id
          )
  
        old_vote_type = vote&.vote_type
  
        vote ||= Vote.new(
          event_id: command.event_id,
          user_id: command.user_id
        )
  
        vote.update!(
          vote_type: command.vote_type
        )
  
        publish_vote_casted(
          vote,
          old_vote_type
        )
  
        vote
      end
  
      private
  
      attr_reader :event_store
  
      def publish_vote_casted(
        vote,
        old_vote_type
      )
        event_store.publish(
          Votes::Casted.new(
            data: {
              event_id: vote.event_id,
              user_id: vote.user_id,
              old_vote_type: old_vote_type,
              vote_type: vote.vote_type
            }
          ),
          stream_name: "VOTE_CASTED"
        )
      end
    end
  end
  