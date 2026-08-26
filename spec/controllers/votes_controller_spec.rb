require "rails_helper"

RSpec.describe VotesController, type: :controller do
  describe "POST #create" do
    let!(:event) do
      create(:event)
    end

    context "when authenticated" do
      before do
        allow(controller)
          .to receive(:clerk)
          .and_return(
            double(
              user: double(
                id: "user_123"
              ),
              session: true
            )
          )
      end

      it "casts a vote through command bus" do
        expect(
          Rails.configuration.command_bus
        ).to receive(:call)
          .with(
            an_instance_of(
              Votes::Cast
            )
          )

        post :create,
             params: {
               event_id: event.id,
               vote_type: "like"
             }
      end

      it "passes correct vote details" do
        expect(
          Rails.configuration.command_bus
        ).to receive(:call) do |command|
          expect(command.event_id)
            .to eq(event.id.to_s)

          expect(command.user_id)
            .to eq("user_123")

          expect(command.vote_type)
            .to eq("like")
        end

        post :create,
             params: {
               event_id: event.id,
               vote_type: "like"
             }
      end

      it "redirects to events page" do
        allow(
          Rails.configuration.command_bus
        ).to receive(:call)

        post :create,
             params: {
               event_id: event.id,
               vote_type: "like"
             }

        expect(response)
          .to redirect_to(events_path)
      end
    end
    context "when user not authenticated" do
        before do
          allow(controller)
            .to receive(:clerk)
            .and_return(
              double(
                user: nil
              )
            )
        end
      
        it "redirects the user to the sign in page" do
          expect {
            post :create,
                 params: {
                   event_id: event.id,
                   vote_type: "like"
                 }
          }.not_to change(Vote, :count)
      
          expect(response)
            .to redirect_to("/sign-in")
        end
      end
  end
end