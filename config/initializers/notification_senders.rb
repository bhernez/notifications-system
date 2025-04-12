# Register all notification senders
Notifications::SenderRegistry.reset!

# Register built-in senders
Notifications::SenderRegistry.register(:sms, Notifications::Senders::Sms)
Notifications::SenderRegistry.register(:email, Notifications::Senders::Email)
Notifications::SenderRegistry.register(:push, Notifications::Senders::Push)

# Third-party developers can register additional senders without modifying the core code:
# Notifications::SenderRegistry.register(:slack, ThirdParty::SlackNotificationSender) 