# Notification System

## Overview

This application is a scalable, extensible notification system designed to send messages through various channels (email, SMS, push). It respects user preferences and uses background jobs for asynchronous processing.

## Requirements

- Ruby 3.4.1
- Rails 8.0.2
- PostgreSQL
- Redis (for background jobs)
- Async Job Adapter (Rails 7+ built-in)

## Setup

```bash
bundle install
bin/rails db:setup
```

## Usage

### Sending Bulk Notifications

You can send notifications to multiple users with:

```ruby
BulkSendNotification.call(
  user_ids: [<user_id_1>, <user_id_2>],
  content: "Your message here",
  channel: "sms", # or "email", "push"
  style: "alert"  # or "reminder", "promotional"
)
```

Only users with a matching preference for the specified channel will receive the notification.

### Notification Preferences

Each user has a notification preference record with booleans like:

```ruby
{
  email_notifications: true,
  sms_notifications: false,
  push_notifications: true
}
```

You can retrieve or update preferences via the `UserNotificationPreference` model.

### Background Processing

Notifications are sent using background jobs via `Notifications::ManagerJob`. Jobs are enqueued asynchronously and will pick up `pending` notifications and dispatch them through the correct sender (e.g., `Notifications::Sender::Sms`).

### Notification Lifecycle

1. `BulkSendNotification` creates a `Notification` record with `status: "pending"`.
2. `ManagerJob` enqueues based on pending notifications.
3. The sender delivers the notification and updates status to `sent` or `failed`.

## Testing

To run tests:

```bash
bundle exec rspec
```

## Extending

To add a new channel (e.g., in-app):

1. Create a sender class under `Notifications::Sender::<NewChannel>`.
2. Add the option to `UserNotificationPreference`.
3. Whitelist the channel in validations within `BulkSendNotification::Form`.

## Design Notes

- Commands encapsulate the business logic.
- Validations are handled in form objects.
- Jobs decouple delivery from user interaction.
- Easily extendable to support more types/channels in the future.
