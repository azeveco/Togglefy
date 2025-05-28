# frozen_string_literal: true

module Togglefy
  # The Config class loads config settings for the Togglefy gem.
  class Config
    # Initializes the configuration for Togglefy.
    def self.initialize_configuration
      # Load feature dependencies
      Togglefy::FeatureDependencyLoader.load_dependencies!
    end

    # Call the method to initialize configuration when the module is loaded.
    # This method is automatically called when the Togglefy module is loaded.
    def self.load
      # Ensure the configuration is initialized only once
      return if defined?(@@configuration_initialized) && @@configuration_initialized

      @@configuration_initialized = true

      # Initialize the configuration
      Togglefy::Config.initialize_configuration
    end
  end
end
