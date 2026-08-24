require "rails_helper"

RSpec.describe Vote, type: :model do
  describe "associations" do
    it "belongs to event" do
      expect(subject)
        .to belong_to(:event)
    end
  end

  describe "validations" do
    subject do
      build(:vote)
    end

    it "validates presence of user_id" do
      expect(subject)
        .to validate_presence_of(:user_id)
    end

    it "validates vote_type inclusion" do
      expect(subject)
        .to validate_inclusion_of(:vote_type)
        .in_array(
          Vote::VOTE_TYPES.keys
        )
    end
  end

  describe "vote types" do
    it "allows like votes" do
      vote =
        build(
          :vote,
          vote_type: "like"
        )

      expect(vote)
        .to be_valid
    end

    it "allows dislike votes" do
      vote =
        build(
          :vote,
          vote_type: "dislike"
        )

      expect(vote)
        .to be_valid
    end

    it "rejects invalid vote types" do
      vote =
        build(
          :vote,
          vote_type: "invalid"
        )

      expect(vote)
        .not_to be_valid
    end
  end
end
