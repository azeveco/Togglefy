# frozen_string_literal: true

require "togglefy/services/bulk_toggler"

module Togglefy
  class ScopedBulkWrapper
    def initialize(klass)
      @klass = klass
    end

    def bulk
      BulkToggler.new(@klass)
    end
  end
end
