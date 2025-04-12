module Notifications
  class ProcessingResult
    attr_reader :notification, :errors
    attr_accessor :delivery

    def initialize(notification)
      @notification = notification
      @errors = []
      @delivery = nil
    end

    def add_errors(new_errors)
      @errors.concat(Array(new_errors))
    end

    def success?
      errors.empty? && delivery&.success?
    end
  end
end 