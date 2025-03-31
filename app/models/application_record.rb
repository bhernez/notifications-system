require "securerandom"

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :maybe_assign_id

  private

  # Generate a UUIDv7 for the `id` column
  # This wouldn't be necessary if the DB supports UUID data type natively
  # like Postgres
  def maybe_assign_id
    return if self.class.attribute_types["id"].type != :string

    self.id ||= SecureRandom.uuid_v7
  end
end
