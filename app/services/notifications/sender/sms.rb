# frozen_string_literal: true

# This class would hold all the logic related to sending a SMS (ex: connecting to API, validating number, etc)
module Notifications
  module Sender
    class Sms < Base
      # It would return either `true` or `false`. The notification object must not be modified
      def perform(notification)
        @notification = notification
        puts "Notifications::Sender::Sms: About to send SMS"
        normalized_phone
        puts "Notifications::Sender::Sms: Sending SMS..."
        sleep 3
        puts "Notifications::Sender::Sms: SMS was sent!"
        true
      end

      private

      # TODO: This could be the initialization of the SMS API SDK/Client
      def client
        puts "Notifications::Sender::Sms: Initializing SMS client"
      end

      # Custom methods specific to the channel
      # TODO: Logic to properly format the stored phone number the way the SMS client needs it
      # (this could even be at creation time)
      def normalized_phone
        puts "Notifications::Sender::Sms: Fetching user's phone number"
        user_sms_preference&.dig("number").tap { puts "Notifications::Sender::Sms: User's phone number: #{_1}" }
      end

      def split_message; end

      # Again, depending on business needs this could either be an array or a record of `UserNotificationPreference`
      def user_sms_preference
        # @notification.user.notification_preferences.sms.first&.preferences
        @notification.user.notification_preferences.select(&:sms?).first&.preferences
      end
    end
  end
end