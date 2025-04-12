module Notifications
  class SenderRegistry
    class << self
      def register(channel, sender_class)
        senders[channel.to_sym] = sender_class
      end

      def for_channel(channel)
        senders[channel.to_sym] || raise(UnsupportedChannelError, "Unsupported channel: #{channel}")
      end

      def reset!
        @senders = {}
      end

      private

      def senders
        @senders ||= {}
      end
    end
  end

  class UnsupportedChannelError < StandardError; end
end 