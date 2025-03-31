# frozen_string_literal: true

class Notification < ApplicationRecord
  # This enum is read from other models, this could maybe be extracted into a application-wide
  # constant (ex: a YML config, constant at initializers level, etc)
  enum :channel,
       { email: "email",
         sms: "sms",
         push: "push" },
       validate: true

  # `type` is a reserved column name for Rails, therefore we use `style`
  enum :style,
       { alert: "alert",
         reminder: "reminder",
         promotional: "promotional" },
       validate: true

  enum :status,
       { pending: "pending",
         sending: "sending",
         sent: "sent",
         error: "error",
         unknown: "unknown" },
       default: "pending",
       validate: true

  belongs_to :user

  validates :channel, presence: true
  validates :style, presence: true
  validates :status, presence: true

  before_create :clean_content_for_sms, if: :sms?

  def mark_as_sent!
    self.sent_at = Time.current
    self.sent!
  end

  private

  def clean_content_for_sms
    # TODO: SMS are 160 chars long and not all ASCII characters
    # are supported so we should pre-process the content to
    # remove chars that could increase the size/cost of SMS
    # self.content = method_to_clean_sms_body(content)
  end
end
