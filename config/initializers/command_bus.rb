Rails.application.config.to_prepare do
  Rails.configuration.command_bus = CommandBus.new
end
