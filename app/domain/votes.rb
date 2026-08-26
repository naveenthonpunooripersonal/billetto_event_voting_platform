module Votes
  def self.subscriptions
    [
      VoteCompletedHandler.subscriptions
    ].reduce(&:merge)
  end
end
