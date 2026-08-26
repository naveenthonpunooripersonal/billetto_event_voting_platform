class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
  
  helper_method :current_user_id, :authenticated?

  private

  def current_user_id
    clerk.user&.id
  end

  def authenticated?
    current_user_id.present?
  end
end