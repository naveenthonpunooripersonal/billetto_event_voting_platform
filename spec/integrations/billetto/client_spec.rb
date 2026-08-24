require "rails_helper"

RSpec.describe Billetto::Client do
  describe "#fetch_events" do
    it "returns billetto events" do
      stub_request(
        :get,
        /billetto.dk/
      )
      .to_return(
        status: 200,
        body: {
          data: [
            {
              id: "123",
              title: "Ruby Conf"
            }
          ]
        }.to_json
      )

      result =
        described_class
        .new
        .fetch_events(
          limit: 1
        )

      expect(result["data"].first["id"])
        .to eq("123")
    end

    it "raises error when API fails" do
      stub_request(
        :get,
        /billetto.dk/
      )
      .to_return(
        status: 500,
        body: "{}"
      )

      expect {
        described_class
          .new
          .fetch_events(limit: 1)
      }
      .to raise_error(
        Billetto::ApiError
      )
    end
  end
end
