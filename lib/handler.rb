module Handler
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def subscribes_to(*events)
      @subscribed_events = events
    end

    def subscriptions
      {
        self => @subscribed_events
      }
    end
  end
end
