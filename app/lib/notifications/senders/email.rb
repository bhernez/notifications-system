module Notifications
  module Senders
    class Email < Base
      private

      def validate!
        raise ValidationError, "User email is required" unless user.email.present?
      end

      def do_deliver
        # Implementation using your email service
        EmailService.deliver(
          to: user.email,
          content: notification.content,
          style: notification.style
        )
        Result.success
      end

      def user
        @user ||= notification.user
      end
    end
  end
end 