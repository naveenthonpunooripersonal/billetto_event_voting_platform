require "rails_helper"

RSpec.describe "Voting", type: :system do
  let!(:event) { create(:event) }

  describe "guest user" do
    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return(nil)

      visit events_path
    end

    it "redirects to sign in when trying to upvote" do
      within("#event-#{event.id}") do
        find("#upvote-event-#{event.id}").click
      end

      expect(page).to have_current_path("/sign-in")
    end

    it "redirects to sign in when trying to downvote" do
      within("#event-#{event.id}") do
        find("#downvote-event-#{event.id}").click
      end

      expect(page).to have_current_path("/sign-in")
    end
  end

  describe "authenticated user" do
    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user_id)
        .and_return("clerk_test_user_123")

      visit events_path
    end

    it "allows the user to upvote an event" do
      within("#event-#{event.id}") do
        find("#upvote-event-#{event.id}").click
      end

      expect(page).to have_current_path(events_path)
    end

    it "allows the user to downvote an event" do
      within("#event-#{event.id}") do
        find("#downvote-event-#{event.id}").click
      end

      expect(page).to have_current_path(events_path)
    end

    it "increases the upvote count when the user upvotes" do
        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (0)")

          find("#upvote-event-#{event.id}").click
        end

        expect(page).to have_current_path(events_path)

        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (1)")
        end
    end

    it "increases the downvote count when the user downvotes" do
        within("#event-#{event.id}") do
          expect(page).to have_button("👎 Downvote (0)")

          find("#downvote-event-#{event.id}").click
        end

        expect(page).to have_current_path(events_path)

        within("#event-#{event.id}") do
          expect(page).to have_button("👎 Downvote (1)")
        end
    end

    it "moves the vote from upvote to downvote" do
        within("#event-#{event.id}") do
          find("#upvote-event-#{event.id}").click
        end

        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (1)")
          expect(page).to have_button("👎 Downvote (0)")
        end

        # Page redirects to events after the first vote, so find the event again.
        within("#event-#{event.id}") do
          find("#downvote-event-#{event.id}").click
        end

        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (0)")
          expect(page).to have_button("👎 Downvote (1)")
        end
    end

    it "moves the vote from downvote to upvote" do
        within("#event-#{event.id}") do
          find("#downvote-event-#{event.id}").click
        end

        within("#event-#{event.id}") do
          expect(page).to have_button("👎 Downvote (1)")
          expect(page).to have_button("👍 Upvote (0)")
        end

        within("#event-#{event.id}") do
          find("#upvote-event-#{event.id}").click
        end

        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (1)")
          expect(page).to have_button("👎 Downvote (0)")
        end
    end

    it "does not create multiple upvotes for the same user and event" do
        within("#event-#{event.id}") do
          find("#upvote-event-#{event.id}").click
        end

        within("#event-#{event.id}") do
          find("#upvote-event-#{event.id}").click
        end

        expect(event.reload.votes.where(user_id: "clerk_test_user_123").count).to eq(1)

        within("#event-#{event.id}") do
          expect(page).to have_button("👍 Upvote (1)")
        end
    end
  end
end
