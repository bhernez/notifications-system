module Notifications
  class ValidationService
    def initialize(notification)
      @notification = notification
      @errors = []
    end

    def valid?
      reset_errors
      validate_notification_state
      validate_user_exists
      validate_channel_enabled
      validate_style_accepted
      errors.empty?
    end

    attr_reader :errors

    private

    attr_reader :notification

    def reset_errors
      @errors = []
    end

    def validate_notification_state
      unless notification.pending?
        errors << "Notification #{notification.id} is not in pending state (current: #{notification.status})"
      end
    end

    def validate_user_exists
      unless notification.user_id.present? && User.exists?(notification.user_id)
        errors << "User #{notification.user_id} does not exist"
      end
    end

    def validate_channel_enabled
      return if errors.any? # Skip if previous validations failed
      
      preferences = fetch_preferences
      return if preferences.nil? # Will be handled by validate_preferences_exist
      
      unless preferences.channel_enabled?(notification.channel)
        errors << "Channel #{notification.channel} is disabled for user #{notification.user_id}"
      end
    end

    def validate_style_accepted
      return if errors.any? # Skip if previous validations failed
      
      preferences = fetch_preferences
      return if preferences.nil? # Will be handled by validate_preferences_exist
      
      unless preferences.style_accepted?(notification.style)
        errors << "Style #{notification.style} is not accepted for user #{notification.user_id}"
      end
    end

    def fetch_preferences
      @preferences ||= begin
        prefs = UserNotificationPreference.for_user_and_channel(notification.user_id, notification.channel)
        if prefs.nil?
          errors << "No preferences found for user #{notification.user_id} and channel #{notification.channel}"
          nil
        else
          PreferenceWrapper.new(prefs)
        end
      end
    end
  end
  
  class PreferenceWrapper
    def initialize(preference)
      @preference = preference
    end
    
    def channel_enabled?(channel)
      return true unless @preference.preferences.key?("enabled")
      @preference.preferences["enabled"] == true
    end
    
    def style_accepted?(style)
      return true unless @preference.preferences.key?("style")
      allowed_styles = @preference.preferences["style"]
      return true if allowed_styles.blank?
      allowed_styles.include?(style)
    end
  end
end 