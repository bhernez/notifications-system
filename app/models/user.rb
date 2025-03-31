class User < ApplicationRecord
  has_many :notification_preferences, class_name: "UserNotificationPreference"

end
