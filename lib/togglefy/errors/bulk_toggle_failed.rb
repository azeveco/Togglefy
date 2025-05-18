# frozen_string_literal: true

module Togglefy
  # The BulkToggleFailed error is raised when a bulk toggle operation fails.
  # This error provides additional context by allowing an optional cause to be specified.
  class BulkToggleFailed < Togglefy::Error
    # Initializes a new BulkToggleFailed error.
    #
    # @param message [String] The error message (default: "Bulk toggle operation failed").
    # @param cause [Exception, nil] The underlying cause of the error, if any.
    # @return [BulkToggleFailed] A new instance of the error.
    def initialize(message = "Bulk toggle operation failed", cause = nil)
      super(message)
      set_backtrace(cause.backtrace) if cause
      @cause = cause
    end

    # @!attribute [r] cause
    #   @return [Exception, nil] The underlying cause of the error, if any.
    attr_reader :cause
  end
end
