FactoryBot.define do
  factory :event do
    billetto_event_id do
      SecureRandom.uuid
    end

    title do
      "Ruby Conference"
    end

    event_url do
      "https://billetto.com/events/test"
    end

    start_date do
      Time.current + 1.day
    end

    description do
      "Ruby and Rails event"
    end

    category do
      "technology"
    end

    address do
      "Hyderabad"
    end
  end
end
