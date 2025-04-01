class NotificationPreferencesController < ApplicationController
  before_action :set_user
  before_action :set_preference, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    @preferences = @user.notification_preferences
    render json: @preferences
  end

  def show
    render json: @preference
  end

  def create
    @preference = @user.notification_preferences.build(preference_params)

    if @preference.save
      render json: @preference, status: :created
    else
      render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @preference.update(preference_params)
      render json: @preference
    else
      render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @preference.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_preference
    @preference = @user.notification_preferences.find(params[:id])
  end

  def preference_params
    params.require(:user_notification_preference).permit(:channel, preferences: {})
  end

  def record_not_found
    head :not_found
  end
end
