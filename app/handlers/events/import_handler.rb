module Events
  class ImportHandler
    def call(command)
      Events::Service.new.call(
        command
      )
    end
  end
end
