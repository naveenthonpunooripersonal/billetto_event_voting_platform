module Events
  class Service
    def initialize(
      billetto_adapter: Billetto::Adapter.new,
      event_store: Rails.configuration.event_store
    )
      @billetto_adapter = billetto_adapter
      @event_store = event_store
    end

    def call(command)
      imported_count = 0

      billetto_adapter.events(limit: command.limit).each do |attributes|
        Event
          .find_or_initialize_by(billetto_event_id: attributes[:billetto_event_id])
          .update!(attributes)

        imported_count += 1
      end

      publish_imported(imported_count)
      imported_count
    end

    private

    attr_reader :billetto_adapter, :event_store

    def publish_imported(count)
      event =
        Events::Imported.new(
          data: {
            count: count
          }
        )

      event_store.publish(
        event,
        stream_name: "EVENTS_IMPORT",
        expected_version: :auto
      )
    end
  end
end
