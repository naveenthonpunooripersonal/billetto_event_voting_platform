require "rails_helper"

RSpec.describe EventsController, type: :controller do
  describe "GET #index" do
    let!(:event1) do
      create(:event)
    end

    let!(:event2) do
      create(:event)
    end

    before do
      allow(controller)
        .to receive(:clerk)
        .and_return(
          double(
            session: true
          )
        )
    end

    it "returns success response" do
      get :index

      expect(response)
        .to have_http_status(:success)
    end

    it "loads all events" do
      get :index

      events =
        controller.instance_variable_get(:@events)

      expect(events)
        .to include(event1, event2)
    end

    it "returns likes count from event_vote_counts" do
      create(
        :event_vote_count,
        event: event1,
        likes_count: 5,
        dislikes_count: 2
      )

      get :index

      events =
        controller.instance_variable_get(:@events)

      event =
        events.find do |record|
          record.id == event1.id
        end

      expect(event.likes_count.to_i)
        .to eq(5)
    end

    it "returns dislikes count from event_vote_counts" do
      create(
        :event_vote_count,
        event: event1,
        likes_count: 5,
        dislikes_count: 2
      )

      get :index

      events =
        controller.instance_variable_get(:@events)

      event =
        events.find do |record|
          record.id == event1.id
        end

      expect(event.dislikes_count.to_i)
        .to eq(2)
    end

    it "returns zero counts when event has no votes" do
      get :index

      events =
        controller.instance_variable_get(:@events)

      event =
        events.find do |record|
          record.id == event2.id
        end

      expect(event.likes_count.to_i)
        .to eq(0)

      expect(event.dislikes_count.to_i)
        .to eq(0)
    end
  end
end
