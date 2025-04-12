module Notifications
  class StatusUpdater
    def initialize(notification)
      @notification = notification
    end

    def update(delivery_result)
      notification.update!(status_attributes(delivery_result))
    end

    private

    attr_reader :notification

    def status_attributes(result)
      {
        status: result.success? ? :sent : :failed,
        sent_at: result.success? ? Time.current : nil,
        error_message: result.success? ? nil : result.error
      }
    end
  end
end 