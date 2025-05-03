# frozen_string_literal: true

require "togglefy/services/bulk_toggler"

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The ScopedBulkWrapper class provides a wrapper for performing bulk operations
  # on a specific class using the BulkToggler service.
  class ScopedBulkWrapper
    # Initializes a new ScopedBulkWrapper.
    #
    # @param klass [Class] The class to perform bulk operations on.
    def initialize(klass)
      @klass = klass
    end

    # Returns a BulkToggler instance for the specified class.
    #
    # @return [BulkToggler] The BulkToggler instance.
    def bulk
      BulkToggler.new(@klass)
    end
  end
end
