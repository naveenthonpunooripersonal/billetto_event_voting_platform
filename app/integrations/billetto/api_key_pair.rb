module Billetto
  class ApiKeyPair

    def self.value
      "#{ENV.fetch('BILLETTO_ACCESS_ID')}:#{ENV.fetch('BILLETTO_SECRET')}"
    end

  end
end