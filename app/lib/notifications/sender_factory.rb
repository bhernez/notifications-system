module Notifications
  class SenderFactory
    SENDER_MAPPING = {
      sms: Senders::Sms,
      email: Senders::Email,
      push: Senders::Push
    }.freeze

    def create_for(channel)
      sender_class = SENDER_MAPPING[channel.to_sym]
      raise UnsupportedChannelError, "Unsupported channel: #{channel}" unless sender_class
      
      sender_class.new
    end
  end

  class UnsupportedChannelError < StandardError; end
end 