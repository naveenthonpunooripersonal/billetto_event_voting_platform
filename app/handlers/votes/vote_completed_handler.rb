module Votes
    class VoteCompletedHandler
      include Handler

      subscribes_to Votes::Casted

      def call(event)
        data = event.data
        vote_count =
          EventVoteCount
            .find_or_initialize_by(
              event_id: data.fetch(:event_id)
            )


        vote_count.with_lock do
          if data[:old_vote_type] == "like"
            vote_count.likes_count -= 1
          end

          if data[:old_vote_type] == "dislike"
            vote_count.dislikes_count -= 1
          end

          if data.fetch(:vote_type) == "like"
            vote_count.likes_count += 1
          end

          if data.fetch(:vote_type) == "dislike"
            vote_count.dislikes_count += 1
          end

          vote_count.save!
        end

        Rails.logger.info(
          "Vote count updated for event #{data.fetch(:event_id)}"
        )
      end
    end
end
