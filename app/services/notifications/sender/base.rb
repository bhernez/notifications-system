# frozen_string_literal: true

module Notifications
  module Sender
    class Base
      def self.send_notification(*)
        new.send_notification(*)
      end

      def send_notification(notification)
        result = perform(notification)
        raise "Result must be a boolean" unless [true, false].include?(result)

        result
      rescue StandardError => e
        Rails.logger.error(e)

        false
      end

      private

      def perform(notification)
        raise "This method must be implemented in the child class"
      end
    end
  end
end
