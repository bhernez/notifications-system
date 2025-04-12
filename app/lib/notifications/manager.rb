module Notifications
  class Manager
    def self.process(notification)
      new(notification).process
    end

    def initialize(notification, 
                  validator: ValidationService.new(notification),
                  sender_factory: SenderFactory.new)
      @notification = notification
      @validator = validator
      @sender_factory = sender_factory
    end

    def process
      ProcessingResult.new(notification).tap do |result|
        if validator.valid?
          deliver_notification(result)
        else
          result.add_errors(validator.errors)
        end
      end
    end

    private

    attr_reader :notification, :validator, :sender_factory

    def deliver_notification(result)
      delivery = DeliveryService.new(notification, find_sender).deliver
      StatusUpdater.new(notification).update(delivery)
      result.delivery = delivery
    end

    def find_sender
      sender_factory.create_for(notification.channel)
    end
  end
end 