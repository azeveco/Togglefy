# frozen_string_literal: true

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The AssignablesNotFound class represents an error raised when no assignables
  # match the provided features and filters.
  class AssignablesNotFound < Togglefy::Error
    # Initializes a new AssignablesNotFound error.
    #
    # @param klass [Class] The class of the assignable.
    def initialize(klass)
      super("No #{klass.name} found matching features and filters sent")
    end
  end
end
