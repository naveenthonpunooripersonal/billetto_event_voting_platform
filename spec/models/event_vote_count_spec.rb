require "rails_helper"

RSpec.describe EventVoteCount, type: :model do
  describe "associations" do
    it "belongs to event" do
      expect(EventVoteCount.new)
        .to belong_to(:event)
    end
  end

  describe "validations" do
    let!(:event) do
      create(:event)
    end

    it "is valid with valid attributes" do
      vote_count =
        build(
          :event_vote_count,
          event: event
        )

      expect(vote_count)
        .to be_valid
    end

    it "allows only one vote count record per event" do
      create(
        :event_vote_count,
        event: event
      )

      duplicate_vote_count =
        build(
          :event_vote_count,
          event: event
        )

      expect(duplicate_vote_count)
        .not_to be_valid
    end
  end

  describe "vote counts" do
    it "stores likes and dislikes count" do
      event =
        create(:event)

      vote_count =
        create(
          :event_vote_count,
          event: event,
          likes_count: 10,
          dislikes_count: 3
        )

      expect(vote_count.likes_count)
        .to eq(10)

      expect(vote_count.dislikes_count)
        .to eq(3)
    end
  end
end
