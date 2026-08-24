module ApplicationSubscriptions
  def self.handlers
    top_level_subscriptions.merge(Events.subscriptions).merge(Votes.subscriptions)
  end

  def self.top_level_subscriptions
    {}
  end
end
