module Events
  class ImportCompletedHandler
    include Handler

    subscribes_to Events::Imported

    def call(event)
      Rails.logger.info("#############Testing Subscriber Mechanism ###############")
      Rails.logger.info("############################mported #{event.data.fetch(:count)} events###########################")
      Rails.logger.info("#############Testing Subscriber Mechanism ###############")
    end
  end
end
