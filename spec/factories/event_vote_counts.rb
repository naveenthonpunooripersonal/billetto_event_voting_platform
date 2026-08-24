FactoryBot.define do
  factory :event_vote_count do
    association :event
  
    likes_count { 0 }
    dislikes_count { 0 }
  end
end