# frozen_string_literal: true

require "togglefy/version"
require "togglefy/engine" if defined?(Rails)
require "togglefy/featureable"
require "togglefy/assignable"
require "togglefy/feature_assignable_manager"
require "togglefy/feature_manager"
require "togglefy/feature_query"
require "togglefy/scoped_bulk_wrapper"
require "togglefy/exceptions"

module Togglefy
  class Error < StandardError; end

  # FeatureQuery
  def self.features
    FeatureQuery.new.features
  end

  def self.feature(identifier)
    FeatureQuery.new.feature(identifier)
  end

  def self.for_type(klass)
    FeatureQuery.new.for_type(klass)
  end

  def self.for_group(group)
    FeatureQuery.new.for_group(group)
  end

  def self.without_group
    FeatureQuery.new.without_group
  end

  def self.for_environment(environment)
    FeatureQuery.new.for_environment(environment)
  end

  def self.without_environment
    FeatureQuery.new.without_environment
  end

  def self.for_tenant(tenant_id)
    FeatureQuery.new.for_tenant(tenant_id)
  end

  def self.without_tenant
    FeatureQuery.new.without_tenant
  end

  def self.for_filters(filters: {})
    FeatureQuery.new.for_filters(filters)
  end

  def self.with_status(status)
    FeatureQuery.new.with_status(status)
  end

  # FeatureManager
  def self.create(**params)
    FeatureManager.new.create(**params)
  end

  def self.update(identifier, **params)
    FeatureManager.new(identifier).update(**params)
  end

  def self.destroy(identifier)
    FeatureManager.new(identifier).destroy
  end

  def self.toggle(identifier)
    FeatureManager.new(identifier).toggle
  end

  def self.active!(identifier)
    FeatureManager.new(identifier).active!
  end

  def self.inactive!(identifier)
    FeatureManager.new(identifier).inactive!
  end

  # FeatureAssignableManager
  def self.for(assignable)
    FeatureAssignableManager.new(assignable)
  end

  # ScopedBulkWrapper
  def self.mass_for(klass)
    Togglefy::ScopedBulkWrapper.new(klass)
  end

  class << self
    # FeatureQuery
    alias for_role for_group
    alias without_role without_group

    alias for_env for_environment
    alias without_env without_environment

    # FeatureManager
    alias create_feature create
    alias update_feature update
    alias toggle_feature toggle
    alias activate_feature active!
    alias inactivate_feature inactive!
    alias destroy_feature destroy
  end
end
