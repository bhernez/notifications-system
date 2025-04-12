module Notifications
  class ValidationService
    def initialize(notification)
      @notification = notification
      @errors = []
    end

    def valid?
      validate_status
      validate_preferences
      validate_style
      errors.empty?
    end

    attr_reader :errors

    private

    attr_reader :notification

    def validate_status
      errors << "Notification must be pending" unless notification.pending?
    end

    def validate_preferences
      unless user_preferences&.enabled_for?(notification.channel)
        errors << "Channel #{notification.channel} is not enabled for user"
      end
    end

    def validate_style
      unless user_preferences&.accepts_style?(notification.style)
        errors << "Style #{notification.style} is not accepted for user"
      end
    end

    def user_preferences
      @user_preferences ||= UserNotificationPreference.for_user(notification.user_id)
    end
  end
end 