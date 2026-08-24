module Events
  class Import
    attr_reader :limit

    def initialize(limit: 10)
      @limit = limit
    end
  end
end