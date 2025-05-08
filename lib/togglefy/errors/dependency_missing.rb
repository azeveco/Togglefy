# frozen_string_literal: true

module Togglefy
  # The DependencyMissing class represents an error raised when a feature
  # is missing a required dependency.
  class DependencyMissing < Togglefy::Error
    # Initializes a new DependencyMissing error.
    #
    # @param feature [String] The name of the feature.
    # @param required [String] The name of the missing dependency.
    def initialize(feature, required)
      super("Feature '#{feature}' is missing dependency: '#{required}'")
    end
  end
end
