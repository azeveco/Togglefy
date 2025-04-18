# frozen_string_literal: true

module Togglefy
  class DependencyMissing < Togglefy::Error
    def initialize(feature, required)
      super("Feature '#{feature}' is missing dependency: '#{required}'")
    end
  end
end
