# frozen_string_literal: true

module Togglefy
  class FeatureNotFound < Togglefy::Error
    def initialize
      super("No features found matching features and/or filters sent")
    end
  end
end
