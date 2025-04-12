module Notifications
  class ManagerJob < ApplicationJob
    queue_as :notifications

    # This job is responsible for orchestrating the delivery of a single Notification.
    # It is enqueued from the `BulkSendNotification` command, usually with a short delay.
    #
    # Upon execution:
    # - It loads the notification with the given ID (if it's still pending).
    # - It delegates the decision-making and sending to `Notifications::Manager`.
    #
    # Notes:
    # - This design helps decouple delivery logic from synchronous user flows.
    # - It also allows retries and better visibility into job-level failures.

    def perform(notification_id)
      notification = Notification.find(notification_id)
      result = Manager.process(notification)
      
      if result.success?
        Rails.logger.info("Notification #{notification_id} delivered successfully")
      else
        Rails.logger.error("Notification #{notification_id} failed: #{result.errors.join(', ')}")
      end
    end

    private

    def retrieve_notification(id)
      # Querying by `id` should be enough for most cases but here we could extend
      # with other custom filters like: only notifications scheduled in the last hour
      Notification.pending.find_by(id:)
    end

    def maybe_send(notification)
      Notifications::Manager.new.notify(notification)
    end
  end
end
