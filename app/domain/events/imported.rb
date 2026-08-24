module Events
  class Imported < RubyEventStore::Event
    SCHEMA = {
      count: Integer
    }.freeze
  end
end