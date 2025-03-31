# frozen_string_literal: true

# BulkSendNotification is a command object responsible for orchestrating
# the creation and asynchronous delivery of multiple notifications to users.
#
# It performs the following steps:
# 1. Validates input data using a dedicated Form object.
# 2. Builds Notification objects in memory for each specified user.
# 3. Persists only the successfully created Notification records.
# 4. Schedules background jobs to process the notifications asynchronously.
#
# Potential Improvements:
# - Filter users by notification preferences before building notifications.
#   (right now this validation happens at `Notifications::Manager`)
# - Log each stage of the delivery pipeline for better observability.
# - Extract channel-specific logic into a strategy or router class.
# - Aggregate and expose errors during persistence.
# - Use bulk inserts or transactional logic for performance/consistency.
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
    # This should be a method that builds the notifications based on the user_ids
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
    # Here we could handle the individual validations errors in an specific way
    # right now this is only excluding non-persisted records
    notifications.filter_map do |notification|
      notification.save
      notification if notification.persisted?
    end
  end

  def schedule_sending(notifications)
    # The `1.minute` delay is hardcoded just for demo purposes, this could be fine-tuned after running performance tests
    # or just simply queued without specific delay and leave the Background Jobs processor decide the best time to
    # pick-up the job
    notifications.each do |notification|
      options = { wait: 1.minute }
      Notifications::ManagerJob.set(**options).perform_later(notification.id)
    end
  end
end
