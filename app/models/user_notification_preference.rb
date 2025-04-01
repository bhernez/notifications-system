# The idea of the model is to store the user's notification preferences in
# the following way:
# - Each user can have multiple notification preferences
# - Each notification preference has a channel (ex: email, sms, push, the ones from Notification model...)
# - Each preference configuration is stored in a JSON column to allow customization per channel
# Samples:
# { user_id: UUID, channel: "email", preferences: { style: ["alert"], frequency: "daily"  } }
# { user_id: UUID, channel: "sms", preferences: { enabled: false, number: "+1987654320" } }
# { user_id: UUID, channel: "push", preferences: { style: ["alert", "reminder"], device_registration_ids: [] } }
#
# If a user has no preference for a channel, or it has the `enabled` property as `false`, it means that the user
# does not want to receive notifications through that channel.
class UserNotificationPreference < ApplicationRecord
  belongs_to :user

  enum :channel, Notification.channels, validate: true

  validates :preferences, presence: true
  # Depending on how the system evolves, this could either allow or not multiple preferences per channel
  # validate_uniqueness_of :channel, scope: :user_id

  # At the beginning the JSON preferences might have to be managed at "usage level", meaning no rigid schema
  # but that could change in the future and `preferences` being turned into several "schema" models like
  # `EmailNotificationPreference`, `SmsNotificationPreference`, `PushNotificationPreference`, etc.
end
