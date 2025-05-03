# frozen_string_literal: true

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The InvalidFeatureAttribute class represents an error raised when an
  # invalid attribute is provided for a Togglefy::Feature.
  class InvalidFeatureAttribute < Togglefy::Error
    # Initializes a new InvalidFeatureAttribute error.
    #
    # @param attr [String] The name of the invalid attribute.
    def initialize(attr)
      super("The attribute '#{attr}' is not valid for Togglefy::Feature.")
    end
  end
end
