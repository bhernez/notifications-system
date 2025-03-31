class NotificationsController < ApplicationController
  rescue_from StandardError, with: :render_internal_error

  def create
    notification = Notification.pending.new(create_params)

    if notification.valid? and notification.save
      Notifications::ManagerJob.perform_later(notification.id)

      render json: { status: "queued", id: notification.id }, status: :accepted
    else
      render json: { status: "error", errors: notification.errors }, status: :unprocessable_entity
    end
  end

  def show
    notification = Notification.find(params[:id])

    render json: notification
  rescue ActiveRecord::RecordNotFound
    render json: { status: "error", message: "Notification not found" }, status: :not_found
  end

  def bulk_create
    result = BulkSendNotification.call(**bulk_send_params)

    render json: { status: "queued", count: result.size, ids: result.map(&:id) }, status: :accepted
  rescue ActiveModel::ValidationError => e
    render json: { status: "error", errors: e.model.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def create_params
    params.permit(:user_id, :content, :channel, :style)
  end

  def bulk_send_params
    params.permit(:content, :channel, :style, user_ids: [])
  end

  def render_internal_error(exception)
    Rails.logger.error(exception)
    render json: {
      status: "error",
      message: "An unexpected error occurred"
    }, status: :internal_server_error
  end
end
