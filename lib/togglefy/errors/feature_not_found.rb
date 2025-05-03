# frozen_string_literal: true

module Togglefy
  # The FeatureNotFound class represents an error raised when no features
  # match the provided criteria or filters.
  class FeatureNotFound < Togglefy::Error
    # Initializes a new FeatureNotFound error.
    def initialize(message = "No features found matching features, identifiers and/or filters sent", cause = nil)
      super(message)
      set_backtrace(cause.backtrace) if cause
      @cause = cause
    end

    # @!attribute [r] cause
    #   @return [Exception, nil] The underlying cause of the error, if any.
    attr_reader :cause
  end
end
