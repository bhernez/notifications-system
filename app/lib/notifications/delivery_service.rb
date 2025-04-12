module Notifications
  class DeliveryService
    def initialize(notification, sender)
      @notification = notification
      @sender = sender
    end

    def deliver
      DeliveryResult.new.tap do |result|
        begin
          result.success = sender.deliver(notification)
        rescue StandardError => e
          result.error = e.message
        end
      end
    end

    private

    attr_reader :notification, :sender
  end

  class DeliveryResult
    attr_accessor :success, :error

    def initialize
      @success = false
      @error = nil
    end

    def success?
      @success
    end
  end
end 