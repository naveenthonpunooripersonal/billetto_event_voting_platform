module Events
  def self.subscriptions
    [
      ImportCompletedHandler.subscriptions
    ].reduce(&:merge)
  end
end
