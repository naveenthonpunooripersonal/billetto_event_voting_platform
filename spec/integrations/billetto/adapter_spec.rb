require "rails_helper"

RSpec.describe Billetto::Adapter do
  let(:client) do
    instance_double(
      Billetto::Client
    )
  end

  subject do
    described_class.new(
      client: client
    )
  end

  describe "#events" do
    before do
      allow(client)
        .to receive(:fetch_events)
        .with(limit: 1)
        .and_return(
          {
            "data" => [
              {
                "id" => "123",
                "title" => "Ruby Conference",
                "description" => "Ruby event",
                "categorization" => {
                  "category" => "Technology"
                },
                "image_link" => "image.png",
                "url" => "https://billetto.com/event",
                "startdate" => "2026-01-01",
                "location" => {
                  "location_name" => "Convention Center",
                  "city" => "London",
                  "country" => "UK"
                }
              }
            ]
          }
        )
    end

    it "fetches events from billetto client" do
      result =
        subject.events(
          limit: 1
        )

      expect(result.size)
        .to eq(1)
    end

    it "normalizes billetto response" do
      event =
        subject.events(
          limit: 1
        ).first

      expect(event)
        .to include(
          billetto_event_id: "123",
          title: "Ruby Conference",
          category: "Technology"
        )
    end

    it "builds address" do
      event =
        subject.events(
          limit: 1
        ).first

      expect(event[:address])
        .to eq(
          "Convention Center, London, UK"
        )
    end
  end
end
