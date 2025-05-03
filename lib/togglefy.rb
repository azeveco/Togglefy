# frozen_string_literal: true

require "togglefy/version"
require "togglefy/engine" if defined?(Rails)
require "togglefy/featureable"
require "togglefy/assignable"
require "togglefy/feature_assignable_manager"
require "togglefy/feature_manager"
require "togglefy/feature_query"
require "togglefy/scoped_bulk_wrapper"
require "togglefy/errors"

# The Togglefy module provides a feature management system.
# It includes methods for querying, creating, updating, toggling, and managing features.
# It also provides a way to manage features for assignable objects.
#
# @example
#   Togglefy.create(identifier: :new_feature, description: "A new feature")
#   Togglefy.update(:new_feature, description: "Updated feature description")
#   Togglefy.toggle(:new_feature)
#   Togglefy.active!(:new_feature)
#   Togglefy.inactive!(:new_feature)
#
module Togglefy
  # Returns all features.
  # @return [Array] List of all features.
  def self.features
    FeatureQuery.new.features
  end

  # Finds a feature by its identifier.
  # @param identifier [String, Symbol] The unique identifier of the feature.
  # @return [Feature] The feature object.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  def self.feature(identifier)
    FeatureQuery.new.feature(identifier)
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Queries features for a specific type.
  # @param klass [Class] The class type to filter features by.
  # @return [Array] List of features for the given type.
  def self.for_type(klass)
    FeatureQuery.new.for_type(klass)
  end

  # Queries features for a specific group.
  # @param group [String, Symbol] The group name to filter features by.
  # @return [Array] List of features for the given group.
  def self.for_group(group)
    FeatureQuery.new.for_group(group)
  end

  # Queries features without a group.
  # @return [Array] List of features without a group.
  def self.without_group
    FeatureQuery.new.without_group
  end

  # Queries features for a specific environment.
  # @param environment [String, Symbol] The environment name to filter features by.
  # @return [Array] List of features for the given environment.
  def self.for_environment(environment)
    FeatureQuery.new.for_environment(environment)
  end

  # Queries features without an environment.
  # @return [Array] List of features without an environment.
  def self.without_environment
    FeatureQuery.new.without_environment
  end

  # Queries features for a specific tenant.
  # @param tenant_id [String] The tenant ID to filter features by.
  # @return [Array] List of features for the given tenant.
  def self.for_tenant(tenant_id)
    FeatureQuery.new.for_tenant(tenant_id)
  end

  # Queries features without a tenant.
  # @return [Array] List of features without a tenant.
  def self.without_tenant
    FeatureQuery.new.without_tenant
  end

  # Queries features based on custom filters.
  # @param filters [Hash] A hash of filters to apply.
  # @return [Array] List of features matching the filters.
  def self.for_filters(filters: {})
    FeatureQuery.new.for_filters(filters)
  end

  # Queries features by their status.
  # @param status [String, Symbol, Integer] The status to filter features by.
  # @return [Array] List of features with the given status.
  def self.with_status(status)
    FeatureQuery.new.with_status(status)
  end

  # Creates a new feature.
  # @note All parameters are optional, except for the name. If sent, it should be a keyword argument.
  #
  # @param name [String] The name of the feature.
  # @param identifier [Symbol, String, nil] The unique identifier for the feature. Optional, it can also be nil or blank
  # @param description [String] A description of the feature.
  # @param group [String, Symbol, nil] The group the feature belongs to.
  # @param environment [String, Symbol, nil] The environment the feature is for.
  # @param tenant_id [String] The tenant ID the feature is for.
  # @param status [String, Symbol, Integer] The status of the feature.
  # @return [Feature] The created feature.
  # @example
  #   Togglefy.create(name: "New Feature", identifier: :new_feature, description: "A new feature")
  #   Togglefy.create(name: "New Feature", identifier: nil, description: "A new feature", group: :admin)
  #   Togglefy.create(name: "New Feature", description: "A new feature", environment: :production, tenant_id: "123abc")
  def self.create(**params)
    FeatureManager.new.create(**params)
  end

  # Updates an existing feature.
  # @note All parameters but the first (identifier) should be keyword arguments.
  #
  # @param identifier [Symbol, String] The unique identifier of the feature.
  # @param name [String] The name of the feature.
  # @param identifier [Symbol, String, nil] The unique identifier for the feature. Optional, it can also be nil or blank
  # @param description [String] A description of the feature.
  # @param group [String, Symbol, nil] The group the feature belongs to.
  # @param environment [String, Symbol, nil] The environment the feature is for.
  # @param tenant_id [String] The tenant ID the feature is for.
  # @param status [String, Symbol, Integer] The status of the feature.
  # @return [Feature] The updated feature.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  # @example
  #   Togglefy.update(:new_feature, name: "Updated Feature", description: "Updated feature description")
  #   Togglefy.update(:new_feature, identifier: :updated_feature, group: :support)
  #   Togglefy.update(:new_feature, environment: :staging, tenant_id: "abc123")
  def self.update(identifier, **params)
    FeatureManager.new(identifier).update(**params)
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Deletes a feature.
  # @param identifier [Symbol, String] The unique identifier of the feature.
  # @return [boolean] True if the feature was deleted, false otherwise.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  def self.destroy(identifier)
    FeatureManager.new(identifier).destroy
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Toggles the status of a feature.
  # @param identifier [Symbol, String] The unique identifier of the feature.
  # @return [boolean] True if the feature was toggled, false otherwise.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  def self.toggle(identifier)
    FeatureManager.new(identifier).toggle
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Activates a feature.
  # @param identifier [Symbol, String] The unique identifier of the feature.
  # @return [boolean] True if the feature was activated, false otherwise.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  def self.active!(identifier)
    FeatureManager.new(identifier).active!
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Deactivates a feature.
  # @param identifier [Symbol, String] The unique identifier of the feature.
  # @return [boolean] True if the feature was inactivated, false otherwise.
  # @raise [Togglefy::FeatureNotFound] If the feature is not found by the identifier.
  def self.inactive!(identifier)
    FeatureManager.new(identifier).inactive!
  rescue ActiveRecord::RecordNotFound
    raise Togglefy::FeatureNotFound, "Couldn't find Togglefy::Feature with identifier '#{identifier}'"
  end

  # Manages features for a specific assignable object.
  # @param assignable [Object] The assignable object.
  # @return [FeatureAssignableManager] The manager for the assignable object.
  def self.for(assignable)
    FeatureAssignableManager.new(assignable)
  end

  # Provides bulk management for a specific class.
  # @param klass [Class] The class to manage features for.
  # @return [ScopedBulkWrapper] The bulk wrapper for the class.
  def self.mass_for(klass)
    Togglefy::ScopedBulkWrapper.new(klass)
  end

  class << self
    # Aliases for group-related Features.
    alias for_role for_group
    alias without_role without_group

    # Aliases for environment-related Features.
    alias for_env for_environment
    alias without_env without_environment

    # Aliases for feature management Features.
    alias create_feature create
    alias update_feature update
    alias toggle_feature toggle
    alias activate_feature active!
    alias inactivate_feature inactive!
    alias destroy_feature destroy
  end
end
