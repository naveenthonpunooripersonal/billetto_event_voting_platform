Rails.application.config.to_prepare do
    event_store = RailsEventStore::JSONClient.new
    ApplicationSubscriptions.handlers.each do |handler, events|
        event_store.subscribe(
          handler.new,
          to: events
        )
      end
      Rails.configuration.event_store = event_store
end
