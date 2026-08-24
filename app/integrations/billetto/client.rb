module Billetto
  class Client
    BASE_URL = "https://billetto.dk/api/v3/public/events"

    def fetch_events(limit: 10)
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(limit: limit)

      request = Net::HTTP::Get.new(uri)
      request["accept"] = "application/json"
      request["Api-Keypair"] = ApiKeyPair.value

      response = execute(request, uri)
      handle_response(response)
    rescue JSON::ParserError
      raise ApiError, "Invalid Billetto response"
    rescue Net::HTTPError => e
      raise ApiError, e.message
    end

    private

    def execute(request, uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(request)
    end

    def handle_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise ApiError, "Billetto API failed #{response.code}"
      end

      JSON.parse(response.body)
    end
  end
end
