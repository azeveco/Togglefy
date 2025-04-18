# frozen_string_literal: true

module Togglefy
  class BulkToggleFailed < Togglefy::Error
    def initialize(message = "Bulk toggle operation failed", cause = nil)
      super(message)
      set_backtrace(cause.backtrace) if cause
      @cause = cause
    end

    attr_reader :cause
  end
end
