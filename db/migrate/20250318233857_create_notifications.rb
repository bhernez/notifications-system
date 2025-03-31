class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.references :user, null: false, foreign_key: true, type: :string
      t.text :content
      # `type` is a reserved column name for Rails
      t.string :style
      t.string :status, index: true
      t.string :channel

      t.timestamp :sent_at
      t.timestamps
    end
  end
end
