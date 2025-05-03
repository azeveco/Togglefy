# frozen_string_literal: true

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The Engine class integrates the Togglefy gem with a Rails application.
  # It isolates the namespace to avoid conflicts with other parts of the application.
  class Engine < ::Rails::Engine
    isolate_namespace Togglefy
  end
end
