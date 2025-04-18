# frozen_string_literal: true

module Togglefy
  class AssignablesNotFound < Togglefy::Error
    def initialize(klass)
      super("No #{klass.name} found matching features and filters sent")
    end
  end
end
