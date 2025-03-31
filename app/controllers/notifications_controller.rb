class NotificationsController < ApplicationController
  def create
  end

  def show
  end

  def bulk_create
    user_ids = bulk_send_params.fetch(:user_ids)

  end

  private

  def create_params
    params.permit(:user_id, :content, :channel, :style)
  end

  def create_notification

  end

  def bulk_send_params
    params.permit(:user_ids, :content, :channel, :style)
  end
end
