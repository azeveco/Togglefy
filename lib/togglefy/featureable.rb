# frozen_string_literal: true

require "togglefy/assignable"

module Togglefy
  Featureable = Assignable
  warn "[DEPRECATION] `Togglefy::Featureable` is deprecated. Use `Togglefy::Assignable` instead."
end
