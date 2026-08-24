FactoryBot.define do
  factory :vote do
    association :event

    user_id do
      "user_123"
    end

    vote_type do
      "like"
    end
  end
end
