module Billetto
  class Adapter
    def initialize(client: Client.new)
      @client = client
    end

    def events(limit:)
      response = client.fetch_events(limit: limit)

      response.fetch("data").map do |event|
        normalize(event)
      end
    end

    private

    attr_reader :client

    def normalize(event)
      {
        billetto_event_id: event.fetch("id"),
        title: event.fetch("title"),
        description: event["description"],
        category: event.dig("categorization", "category"),
        image_url: event["image_link"],
        event_url: event["url"],
        start_date: event["startdate"],
        address: build_address(event["location"])
      }
    end

    def build_address(location)
      return nil unless location

      [
        location["location_name"],
        location["address_line"],
        location["city"],
        location["postal_code"],
        location["country"]
      ].compact.join(", ")
    end
  end
end
