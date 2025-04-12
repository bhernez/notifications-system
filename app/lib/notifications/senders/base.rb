module Notifications
  module Senders
    class Base
      def initialize(notification)
        @notification = notification
      end

      def deliver
        validate!
        do_deliver
      rescue StandardError => e
        Result.failure(e.message)
      end

      private

      attr_reader :notification

      def validate!
        raise NotImplementedError, "Subclasses must implement validate!"
      end

      def do_deliver
        raise NotImplementedError, "Subclasses must implement do_deliver"
      end
    end
  end
end 