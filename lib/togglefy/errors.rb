# frozen_string_literal: true

# This file loads all custom exception classes used in the Togglefy gem.
require "togglefy/errors/error"

require "togglefy/errors/feature_not_found"
require "togglefy/errors/assignables_not_found"
require "togglefy/errors/bulk_toggle_failed"

module Togglefy
  # Custom error class for Togglefy-specific errors.
  class Error < ::StandardError; end

  # Overwrites the default StandardError class to provide a custom error class for Togglefy.
  StandardError = Class.new(Error)
end
