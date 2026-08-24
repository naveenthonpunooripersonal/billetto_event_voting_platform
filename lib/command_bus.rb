class CommandBus
  def initialize
    @handlers = {
      Events::Import => Events::ImportHandler.new,
      Votes::Cast => Votes::CastHandler.new
    }
  end

  def call(command)
    handler =
      @handlers.fetch(
        command.class
      )

    handler.call(command)
  end
end