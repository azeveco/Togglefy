# frozen_string_literal: true

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The FeatureAssignableManager class provides methods to manage features
  # for an assignable object, such as enabling, disabling, and clearing features.
  class FeatureAssignableManager
    # Initializes a new FeatureAssignableManager.
    #
    # @param assignable [Object] The assignable object to manage features for.
    def initialize(assignable)
      @assignable = assignable
    end

    # Enables a feature for the assignable.
    #
    # @param feature [Togglefy::Feature, Symbol, String] The feature or its identifier.
    # @return [FeatureAssignableManager] Returns self for method chaining.
    def enable(feature)
      assignable.add_feature(feature)
      self
    end

    # Disables a feature for the assignable.
    #
    # @param feature [Togglefy::Feature, Symbol, String] The feature or its identifier.
    # @return [FeatureAssignableManager] Returns self for method chaining.
    def disable(feature)
      assignable.remove_feature(feature)
      self
    end

    # Clears all features from the assignable.
    #
    # @return [FeatureAssignableManager] Returns self for method chaining.
    def clear
      assignable.clear_features
      self
    end

    # Checks if the assignable has a specific feature.
    #
    # @param feature [Togglefy::Feature, Symbol, String] The feature or its identifier.
    # @return [Boolean] True if the feature exists, false otherwise.
    def has?(feature)
      assignable.has_feature?(feature)
    end

    private

    # @return [Object] The assignable object being managed.
    attr_reader :assignable
  end
end
