require "faker"

puts "Seeding users and preferences..."

channels = %w[sms email push]
styles = %w[alert reminder promotional]

# Create users
users = 5.times.map do |i|
  User.find_or_create_by!(email: "user_#{i}@lvh.me")
end

# Assign varied preferences
users.each_with_index do |user, i|
  channels.each do |channel|
    enabled = i.even? || channel == "email"
    style = styles.sample(2)
    UserNotificationPreference.find_or_create_by!(
      user_id: user.id,
      channel: channel
    ) do |pref|
      pref.preferences = {
        enabled: enabled,
        style: style
      }.tap do |prefs|
        prefs[:number] = Faker::PhoneNumber.cell_phone_in_e164 if channel == "sms"
      end
    end
  end

  puts "-" * 60
  puts "User: #{user.id}"
  user.notification_preferences.each do |pref|
    puts "  Channel: #{pref.channel}"
    pref.preferences.each do |key, value|
      puts "    #{key}: #{value}"
    end
  end
  puts "-" * 60
end

puts "Seeding completed."
