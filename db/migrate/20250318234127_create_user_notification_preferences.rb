class CreateUserNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_notification_preferences, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.references :user, null: false, foreign_key: true, type: :string
      t.string :channel
      t.json :preferences

      t.timestamps
    end
  end
end
