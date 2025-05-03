# frozen_string_literal: true

# The Togglefy module serves as the namespace for the gem.
module Togglefy
  # The FeatureManager class provides methods to manage features, including
  # creating, updating, toggling, and destroying them.
  class FeatureManager
    # Initializes a new FeatureManager.
    #
    # nil only applies when creating a new feature.
    #
    # @param identifier [String, nil] The identifier of the feature to manage.
    def initialize(identifier = nil)
      @identifier = identifier unless identifier.nil?
    end

    # Creates a new feature with the given parameters.
    #
    # @param params [Hash] The attributes for the new feature.
    # @return [Togglefy::Feature] The created feature.
    def create(**params)
      Togglefy::Feature.create!(**params)
    end

    # Updates the feature with the given parameters.
    #
    # @param params [Hash] The attributes to update the feature with.
    # @return [Togglefy::Feature] The updated feature.
    def update(**params)
      feature.update!(**params)
    end

    # Destroys the feature.
    #
    # @return [Togglefy::Feature] The destroyed feature.
    def destroy
      feature.destroy
    end

    # Toggles the feature's status between active and inactive.
    #
    # @return [Togglefy::Feature] The toggled feature.
    def toggle
      return feature.inactive! if feature.active?

      feature.active!
    end

    # Activates the feature.
    #
    # @return [Togglefy::Feature] The activated feature.
    def active!
      feature.active!
    end

    # Deactivates the feature.
    #
    # @return [Togglefy::Feature] The deactivated feature.
    def inactive!
      feature.inactive!
    end

    private

    # @return [String, nil] The identifier of the feature being managed.
    attr_reader :identifier

    # Finds the feature by its identifier.
    #
    # @return [Togglefy::Feature] The found feature.
    def feature
      Togglefy::Feature.find_by!(identifier: identifier)
    end
  end
end
