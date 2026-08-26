class PrivatePagesController < ApplicationController
  before_action :require_clerk_session!

  private

  def require_clerk_session!
    return if authenticated?
    redirect_to "/sign-in"
  end
end
