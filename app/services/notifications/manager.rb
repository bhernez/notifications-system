# frozen_string_literal: true

module Notifications
  # The name might not be the best, but the idea is to have a class that performs the decision of when to send a Notification
  # This class could be responsible for scheduling the notification to be sent at a specific time or decide not to
  # send it based on User's preference.
  # This class will call the appropriate Sender class to send the notification
  class Manager
    # It would return the same Notification object with the status updated
    def notify(notification)
      begin
        maybe_notify(notification)
      rescue StandardError => e
        Rails.logger.error(e)

        notification.unknown!
      end
    end

    private

    # It would return the same Notification object with the status updated
    def maybe_notify(notification)
      user = notification.user
      return false unless should_send?(user, notification)

      sender = retrieve_sender(notification)
      return false unless sender.present?

      sender.send_notification(notification)
            .then { |result| result ? notification.mark_as_sent! : notification.error! }
    end

    def should_send?(user, notification)
      # Validations about the user's preferences
      # This could call specific validation classes
      preference = UserNotificationPreference.find_by(
        user_id: user.id,
        channel: notification.channel
      )

      return false if preference.nil?

      # Default behavior: do not send if explicitly disabled
      enabled = preference.preferences.fetch("enabled", true)
      return false unless enabled

      # Check if the user only wants specific styles
      allowed_styles = preference.preferences["style"]
      return false if allowed_styles.present? && !allowed_styles.include?(notification.style)

      true
    end

    def retrieve_sender(notification)
      # This could be a factory that returns the correct sender based on the notification's channel
      # or style. It returns an instance of a subclass of Notifications::Sender::Base
      case notification.channel
      when Notification.channels[:sms] then Notifications::Sender::Sms.new
      else nil
      end
    end
  end
end