class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
end