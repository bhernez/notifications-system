# frozen_string_literal: true

class Response
  attr_reader :data, :error

  private_class_method :new

  def initialize(success:, data: nil, error: nil)
    @success = success
    @data = data
    @error = error
  end

  def self.success(data)
    new(success: true, data:)
  end

  def self.failure(error, data:)
    new(success: false, error:, data:)
  end

  def success?
    @success
  end

  def failure?
    !success?
  end
end
