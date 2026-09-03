require "rails_helper"

RSpec.describe Votes::Service do
  let(:event_store) do
    instance_double(
      RailsEventStore::JSONClient,
      publish: true
    )
  end

  subject do
    described_class.new(
      event_store: event_store
    )
  end

  describe "#call" do
    let!(:event) do
      create(:event)
    end

    let(:command) do
      Votes::Cast.new(
        event_id: event.id,
        user_id: "user_123",
        vote_type: "like"
      )
    end

    it "creates a vote" do
      expect {
        subject.call(command)
      }
      .to change(Vote, :count)
      .by(1)
    end

    it "updates existing vote for same user and event" do
      create(
        :vote,
        event: event,
        user_id: "user_123",
        vote_type: "dislike"
      )

      expect {
        subject.call(command)
      }
      .not_to change(Vote, :count)

      expect(
        Vote.last.vote_type
      )
      .to eq("like")
    end

    it "publishes Votes::Casted event" do
      expect(event_store)
        .to receive(:publish)
        .with(
          an_instance_of(
            Votes::Casted
          ),
          stream_name: "VOTE_CASTED_#{event.id}",
          expected_version: :auto
        )

      subject.call(command)
    end
  end
end
