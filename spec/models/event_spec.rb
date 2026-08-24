require "rails_helper"

RSpec.describe Event, type: :model do
  describe "validations" do
    let(:event) do
      build(:event)
    end

    it "is valid with valid attributes" do
      expect(event)
        .to be_valid
    end

    it "requires billetto_event_id" do
      event.billetto_event_id = nil

      expect(event)
        .not_to be_valid
    end

    it "requires unique billetto_event_id" do
      create(
        :event,
        billetto_event_id: "same-id"
      )

      duplicate_event =
        build(
          :event,
          billetto_event_id: "same-id"
        )

      expect(duplicate_event)
        .not_to be_valid
    end

    it "requires title" do
      event.title = nil

      expect(event)
        .not_to be_valid
    end

    it "requires event_url" do
      event.event_url = nil

      expect(event)
        .not_to be_valid
    end

    it "requires start_date" do
      event.start_date = nil

      expect(event)
        .not_to be_valid
    end
  end

  describe "associations" do
    it "has many votes" do
      expect(Event.new)
        .to have_many(:votes)
        .dependent(:destroy)
    end

    it "has one event_vote_count" do
      expect(Event.new)
        .to have_one(:event_vote_count)
    end
  end

  describe "dependent destroy" do
    it "destroys associated votes when event is destroyed" do
      event =
        create(:event)

      create(
        :vote,
        event: event
      )

      expect {
        event.destroy
      }
      .to change(
        Vote,
        :count
      )
      .by(-1)
    end
  end
end
