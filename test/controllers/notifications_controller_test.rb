require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should create and queue notification with valid params" do
    user = User.create!(email: "test@example.com")

    post notifications_url, params: {
      user_id: user.id,
      content: "Hello!",
      channel: "sms",
      style: "alert"
    }

    assert_response :accepted
    body = JSON.parse(response.body)
    assert_equal "queued", body["status"]
    assert body["id"].present?
  end

  test "should create notification and remain pending before job processes it" do
    user = User.create!(email: "delayed@example.com")

    post notifications_url, params: {
      user_id: user.id,
      content: "Pending test",
      channel: "sms",
      style: "alert"
    }

    assert_response :accepted
    body = JSON.parse(response.body)
    id = body["id"]
    assert id.present?

    notification = Notification.find(id)
    assert_equal "pending", notification.status
    assert_nil notification.sent_at
  end

  test "should return error on validation failure" do
    post notifications_url, params: {
      content: "", # invalid content
      channel: "unknown", # invalid channel
      style: "alert"
    }

    assert_response :unprocessable_entity

    body = JSON.parse(response.body)
    assert_equal "error", body["status"]
    assert body["errors"].any?
  end

  test "should return notification by id" do
    user = User.create!(email: "show@example.com")
    notification = Notification.create!(
      user: user,
      content: "Test content",
      channel: "sms",
      style: "alert",
      status: "sent"
    )

    get notification_url(notification)

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal notification.id, body["id"]
    assert_equal "Test content", body["content"]
    assert_equal "sms", body["channel"]
    assert_equal "alert", body["style"]
    assert_equal "sent", body["status"]
  end

  test "should return not found for invalid id" do
    get notification_url("non-existent-id")

    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "error", body["status"]
    assert_equal "Notification not found", body["message"]
  end

  test "should create notification, check pending status, wait for processing, check sent status" do
    user = User.create!(email: "delayed@example.com")
    UserNotificationPreference.create!(user: user, channel: "sms", preferences: { number: "+1987654320" })

    # Enqueue notification
    post notifications_url, params: {
      user_id: user.id,
      content: "Pending test",
      channel: "sms",
      style: "alert"
    }

    assert_response :accepted
    notification_id = JSON.parse(response.body)["id"]

    # Check immediate status
    get notification_url(notification_id)
    assert_equal "pending", JSON.parse(response.body)["status"]

    # "Wait" for notification to be processed
    perform_enqueued_jobs
    assert_performed_jobs 1

    # Check status again
    get notification_url(notification_id)
    assert_equal "sent", JSON.parse(response.body)["status"]
  end

  test "should bulk create notifications with valid params" do
    users = 2.times.map { User.create!(email: Faker::Internet.email) }

    post bulk_notifications_url, params: {
      user_ids: users.map(&:id),
      content: "Bulk content",
      channel: "sms",
      style: "alert"
    }

    assert_response :accepted
    body = JSON.parse(response.body)
    assert_equal "queued", body["status"]
    assert_equal 2, body["count"]
    assert body["ids"].any?
  end

  test "should return error for invalid bulk params" do
    post bulk_notifications_url, params: {
      user_ids: [],
      content: "", # missing content
      channel: "unknown", # invalid
      style: ""
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_equal "error", body["status"]
    assert body["errors"].any?
  end

  test "should handle unexpected errors gracefully" do
    NotificationsController.any_instance.stubs(:create).raises(StandardError, "Something went wrong")

    post notifications_url, params: {
      user_id: "123",
      content: "Trigger error",
      channel: "sms",
      style: "alert"
    }

    assert_response :internal_server_error
    body = JSON.parse(response.body)
    assert_equal "error", body["status"]
    assert_equal "An unexpected error occurred", body["message"]
  end

end
