# Notification System

## Overview

This Rails application implements a scalable notification system that supports delivering messages to users via multiple channels (SMS, Email, Push). The system is designed for extensibility, respects user preferences, and offloads delivery to background jobs for asynchronous processing.

## Requirements

- Ruby 3.4.1
- Rails 8.0.2
- PostgreSQL
- Redis (for job scheduling)
- Async Adapter (Rails 7+ default)

## Setup

```bash
bundle install
bin/rails db:setup
```

## Usage

### API Endpoints

#### `POST /notifications`

Creates a notification for a single user.

Example payload:
```json
{
  "user_id": "uuid-or-id",
  "content": "Hello World!",
  "channel": "sms",
  "style": "alert"
}
```

#### `POST /notifications/bulk`

Creates notifications for multiple users at once using the `BulkSendNotification` command.

Example payload:
```json
{
  "user_ids": ["uuid1", "uuid2"],
  "content": "System maintenance notice",
  "channel": "email",
  "style": "reminder"
}
```

#### `GET /notifications/:id`

Returns the status and metadata of a given notification.

### Notification Lifecycle

1. A notification is created with status `pending`.
2. A background job (`Notifications::ManagerJob`) is scheduled.
3. The job finds the `pending` notification and sends it via the correct `Sender` class.
4. The notification status is updated to `sent` or `failed`.

### User Notification Preferences

User preferences are stored in the `UserNotificationPreference` model and allow for per-channel configuration:

Example:
```json
{
  "channel": "sms",
  "preferences": {
    "enabled": true,
    "style": ["alert", "reminder"]
  }
}
```

These preferences are respected during delivery — if a user has disabled a channel or filtered styles, the notification is skipped.

### Background Job System

- Uses ActiveJob's Async adapter.
- Each notification is handled individually via `Notifications::ManagerJob`.
- Background jobs ensure scalability and fault isolation.

## Development

### Running Tests

```bash
bundle exec rails test
```

Includes tests for:

- API endpoints (`NotificationsController`)
- Command logic (`BulkSendNotification`)
- Delivery jobs (`ManagerJob`)
- Preference-based filtering

### Extending the System

To add a new channel (e.g., in-app):

1. Create a new sender class in `app/lib/notifications/sender/<channel>.rb`.
2. Update `UserNotificationPreference` to include the new channel.
3. Update validation logic in `BulkSendNotification::Form` if necessary.
4. Plug in the sender via `Notifications::Manager`.

## Design Highlights

- Command pattern via `CommandBase` and `CommandForm`
- Dynamic form validation
- Per-user channel preferences
- Job-based delivery queue
- Easily extensible architecture

## Known Improvements (WIP)

- Add throttling or deduplication filters
- Batch job execution for bulk messages
- Retry or fallback mechanism for failed deliveries
- API authentication and rate-limiting

---
Built for scalability, tested for reliability, and designed for growth.
