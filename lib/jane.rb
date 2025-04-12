# frozen_string_literal: true

require "jane/version"
require "jane/engine"
require "jane/featureable"
require "jane/feature_manager"
require "jane/feature_query"

module Jane
  class Error < StandardError; end

  def self.feature(identifier)
    FeatureQuery.new.feature(identifier)
  end

  def self.destroy_feature(identifier)
    FeatureQuery.new.destroy_feature(identifier)
  end
  
  def self.for(assignable)
    FeatureManager.new(assignable)
  end
  
  def self.for_type(klass)
    FeatureQuery.new.for_type(klass)
  end
  
  def self.for_group(klass)
    FeatureQuery.new.for_group(klass)
  end

  def self.without_group
    FeatureQuery.new.without_group
  end

  def self.for_environment(env)
    FeatureQuery.new.for_environment(env)
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

  class <<self
    alias_method :for_role, :for_group
    alias_method :without_role, :without_group

    alias_method :for_env, :for_environment
    alias_method :without_env, :without_environment
  end
end
