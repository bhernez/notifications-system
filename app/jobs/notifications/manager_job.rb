module Notifications
  class ManagerJob < ApplicationJob
    queue_as :default

    def perform(notification_id)
      Notification.pending.find_by(id: notification_id)&.then do |notification|
        Notifications::Manager.new.notify(notification)
      end
    end
  end
end