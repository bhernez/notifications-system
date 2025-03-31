# frozen_string_literal: true

class BulkSendNotification < CommandBase
  class Form < CommandForm
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations

    attr_accessor :user_ids
    attribute :content, :string
    attribute :channel, :string
    attribute :style, :string

    validates :user_ids, presence: true
    validates :content, presence: true
    validates :channel, presence: true, inclusion: { in: Notification.channels }
    validates :style, presence: true, inclusion: { in: Notification.styles }
  end

  def call
    validate
      .then { build_notifications }
      .then { persist_records(_1) }
      .then { schedule_sending(_1) }
  end

  private

  def build_notifications
    # This could be a method that builds the notifications based on the user_ids
    form.user_ids.map do |user_id|
      Notification.pending.new(
        channel: form.channel,
        content: form.content,
        style: form.style,
        user_id:
      )
    end
  end

  def persist_records(notifications)
    notifications.filter_map do |notification|
      notification.save
      notification if notification.persisted?
    end
  end

  def schedule_sending(notifications)
    notifications.each do |notification|
      Notifications::ManagerJob.set(wait: 1.minute).perform_later(notification.id)
    end
  end
end
