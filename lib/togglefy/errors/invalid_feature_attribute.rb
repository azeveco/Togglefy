# frozen_string_literal: true

module Togglefy
  class InvalidFeatureAttribute < Togglefy::Error
    def initialize(attr)
      super("The attribute '#{attr}' is not valid for Togglefy::Feature.")
    end
  end
end
