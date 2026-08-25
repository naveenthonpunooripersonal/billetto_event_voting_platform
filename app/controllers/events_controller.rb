class EventsController < PublicPagesController
  def index
    @events =
      Event
        .joins(
          "LEFT JOIN event_vote_counts
          ON event_vote_counts.event_id = events.id"
        )
        .select(
          "events.*,
          COALESCE(event_vote_counts.likes_count,0) AS likes_count,
          COALESCE(event_vote_counts.dislikes_count,0) AS dislikes_count"
        )
  end
end