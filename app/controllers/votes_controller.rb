class VotesController < PrivatePagesController
  def create
    Rails.configuration.command_bus.call(
      Votes::Cast.new(
        event_id: params[:event_id],
        user_id: current_user_id,
        vote_type: params[:vote_type]
      )
    )

    redirect_to events_path
  end
end
