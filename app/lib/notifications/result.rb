module Notifications
  class Result
    attr_reader :error

    def self.success
      new(success: true)
    end

    def self.failure(error)
      new(success: false, error: error)
    end

    def initialize(success:, error: nil)
      @success = success
      @error = error
    end

    def success?
      @success
    end
  end
end 