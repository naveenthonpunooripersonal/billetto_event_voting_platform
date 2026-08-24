require "rails_helper"

RSpec.describe Votes::VoteCompletedHandler do
  let(:handler) do
    described_class.new
  end

  let!(:event_record) do
    create(:event)
  end

  describe "#call" do
    context "when user likes an event first time" do
      it "increments likes count" do
        event =
          Votes::Casted.new(
            data: {
              event_id: event_record.id,
              user_id: "user_1",
              old_vote_type: nil,
              vote_type: "like"
            }
          )

        handler.call(event)

        vote_count =
          EventVoteCount.find_by(
            event_id: event_record.id
          )

        expect(vote_count.likes_count)
          .to eq(1)

        expect(vote_count.dislikes_count)
          .to eq(0)
      end
    end

    context "when user dislikes an event first time" do
      it "increments dislikes count" do
        event =
          Votes::Casted.new(
            data: {
              event_id: event_record.id,
              user_id: "user_1",
              old_vote_type: nil,
              vote_type: "dislike"
            }
          )

        handler.call(event)

        vote_count =
          EventVoteCount.find_by(
            event_id: event_record.id
          )

        expect(vote_count.likes_count)
          .to eq(0)

        expect(vote_count.dislikes_count)
          .to eq(1)
      end
    end

    context "when user changes like to dislike" do
      before do
        create(
          :event_vote_count,
          event: event_record,
          likes_count: 1,
          dislikes_count: 0
        )
      end

      it "decreases likes and increases dislikes" do
        event =
          Votes::Casted.new(
            data: {
              event_id: event_record.id,
              user_id: "user_1",
              old_vote_type: "like",
              vote_type: "dislike"
            }
          )

        handler.call(event)

        vote_count =
          EventVoteCount.find_by(
            event_id: event_record.id
          )

        expect(vote_count.likes_count)
          .to eq(0)

        expect(vote_count.dislikes_count)
          .to eq(1)
      end
    end

    context "when user changes dislike to like" do
      before do
        create(
          :event_vote_count,
          event: event_record,
          likes_count: 0,
          dislikes_count: 1
        )
      end

      it "decreases dislikes and increases likes" do
        event =
          Votes::Casted.new(
            data: {
              event_id: event_record.id,
              user_id: "user_1",
              old_vote_type: "dislike",
              vote_type: "like"
            }
          )

        handler.call(event)

        vote_count =
          EventVoteCount.find_by(
            event_id: event_record.id
          )

        expect(vote_count.likes_count)
          .to eq(1)

        expect(vote_count.dislikes_count)
          .to eq(0)
      end
    end
  end
end
