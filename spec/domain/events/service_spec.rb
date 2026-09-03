require "rails_helper"

RSpec.describe Events::Service do
  let(:adapter) do
    instance_double(
      Billetto::Adapter
    )
  end

  let(:event_store) do
    instance_double(
      RailsEventStore::JSONClient,
      publish: true
    )
  end

  subject do
    described_class.new(
      billetto_adapter: adapter,
      event_store: event_store
    )
  end

  describe "#call" do
    let(:command) do
      Events::Import.new(
        limit: 2
      )
    end

    let(:billetto_events) do
      [
        {
          billetto_event_id: "billetto_1",
          title: "Ruby Conference",
          event_url: "https://example.com",
          start_date: Time.current
        },
        {
          billetto_event_id: "billetto_2",
          title: "Rails Conference",
          event_url: "https://example.com/rails",
          start_date: Time.current
        }
      ]
    end

    before do
      allow(adapter)
        .to receive(:events)
        .with(limit: 2)
        .and_return(
          billetto_events
        )
    end

    it "imports events" do
      expect {
        subject.call(command)
      }
      .to change(Event, :count)
      .by(2)
    end

    it "publishes Events::Imported event" do
      expect(event_store)
        .to receive(:publish)
        .with(
          an_instance_of(
            Events::Imported
          ),
          stream_name: "EVENTS_IMPORT",
          expected_version: :auto
        )

      subject.call(command)
    end

    it "returns imported count" do
      result =
        subject.call(command)

      expect(result)
        .to eq(2)
    end
  end
end
