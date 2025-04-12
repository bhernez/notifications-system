module Notifications
  class SenderFactory
    def create_for(channel)
      sender_class = SenderRegistry.for_channel(channel)
      sender_class.new
    end
  end

  class UnsupportedChannelError < StandardError; end
end 