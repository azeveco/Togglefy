# frozen_string_literal: true

require "togglefy/assignable"

module Togglefy
  # `Featureable` is an alias for `Assignable`.
  #
  # @deprecated Use `Togglefy::Assignable` instead.
  Featureable = Assignable
  warn "[DEPRECATION] `Togglefy::Featureable` is deprecated. Use `Togglefy::Assignable` instead."
end
