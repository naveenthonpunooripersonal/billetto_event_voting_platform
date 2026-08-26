module Votes
  class CastHandler
    def call(command)
      Votes::Service.new.call(command)
    end
  end
end
