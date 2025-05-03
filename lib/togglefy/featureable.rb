# frozen_string_literal: true

require "togglefy/assignable"

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # `Featureable` is an alias for `Assignable`.
  #
  # @deprecated Use `Togglefy::Assignable` instead.
  Featureable = Assignable
  warn "[DEPRECATION] `Togglefy::Featureable` is deprecated. Use `Togglefy::Assignable` instead."
end
