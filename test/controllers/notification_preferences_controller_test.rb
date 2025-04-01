require "test_helper"

class UserNotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @preference = user_notification_preferences(:one)
  end

  test "should get index" do
    get notification_preferences_url(@user), as: :json
    assert_response :success
  end

  test "should create preference" do
    assert_difference('UserNotificationPreference.count') do
      post notification_preferences_url(@user), params: { user_notification_preference: { channel: @preference.channel, preferences: @preference.preferences } }, as: :json
    end

    assert_response 201
  end

  test "should not create preference with invalid data" do
    assert_no_difference('UserNotificationPreference.count') do
      post notification_preferences_url(@user), params: {
        user_notification_preference: { channel: nil, preferences: {} }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  test "should show preference" do
    get notification_preference_url(@user, @preference), as: :json
    assert_response :success
  end

  test "should return not found for non-existent user" do
    get notification_preferences_url(user_id: "non-existent"), as: :json
    assert_response :not_found
  end

  test "should return not found for invalid preference id" do
    get notification_preference_url(@user, id: "invalid-id"), as: :json
    assert_response :not_found
  end

  test "should update preference" do
    patch notification_preference_url(@user, @preference), params: { user_notification_preference: { channel: @preference.channel, preferences: @preference.preferences } }, as: :json
    assert_response 200
  end

  test "should destroy preference" do
    assert_difference('UserNotificationPreference.count', -1) do
      delete notification_preference_url(@user, @preference), as: :json
    end

    assert_response 204
  end
end
