Clerk.configure do |config|
    config.secret_key = ENV.fetch("CLERK_SECRET_KEY")
end

if Rails.env.test?
  Rails.application.config.middleware.delete Clerk::Rack::Middleware
end