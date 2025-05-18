# frozen_string_literal: true

module Togglefy
  # The FeatureQuery class provides methods to query features based on various filters.
  class FeatureQuery
    # A mapping of filter keys to their corresponding query scopes.
    FILTERS = {
      identifier: :identifier,
      group: :for_group,
      role: :for_group,
      environment: :for_environment,
      env: :for_environment,
      tenant_id: :for_tenant,
      status: :with_status
    }.freeze

    # Retrieves all features.
    #
    # @return [ActiveRecord::Relation] A relation of all features.
    def features
      Togglefy::Feature.all
    end

    # Finds a feature by its identifier.
    #
    # @param identifier [Symbol, Array<Symbol>, String, Array<String>] The identifier(s) of the feature(s).
    # @return [Togglefy::Feature, ActiveRecord::Relation] The feature or features matching the identifier(s).
    def feature(identifier)
      return Togglefy::Feature.identifier(identifier) if identifier.is_a?(Array)

      Togglefy::Feature.find_by!(identifier: identifier)
    end

    # Retrieves feature assignments for a specific type.
    #
    # @param klass [Class] The class type to filter by.
    # @return [ActiveRecord::Relation] A relation of feature assignments for the given type.
    def for_type(klass)
      Togglefy::FeatureAssignment.for_type(klass)
    end

    # Retrieves features for a specific group.
    #
    # @param group [Symbol, String] The group to filter by.
    # @return [ActiveRecord::Relation] A relation of features for the given group.
    def for_group(group)
      Togglefy::Feature.for_group(group)
    end

    # Retrieves features without a group.
    #
    # @return [ActiveRecord::Relation] A relation of features without a group.
    def without_group
      Togglefy::Feature.without_group
    end

    # Retrieves features for a specific environment.
    #
    # @param environment [Symbol, String] The environment to filter by.
    # @return [ActiveRecord::Relation] A relation of features for the given environment.
    def for_environment(environment)
      Togglefy::Feature.for_environment(environment)
    end

    # Retrieves features without an environment.
    #
    # @return [ActiveRecord::Relation] A relation of features without an environment.
    def without_environment
      Togglefy::Feature.without_environment
    end

    # Retrieves features for a specific tenant.
    #
    # @param tenant_id [String] The tenant_id to filter by.
    # @return [ActiveRecord::Relation] A relation of features for the given tenant.
    def for_tenant(tenant_id)
      Togglefy::Feature.for_tenant(tenant_id)
    end

    # Retrieves features without a tenant.
    #
    # @return [ActiveRecord::Relation] A relation of features without a tenant.
    def without_tenant
      Togglefy::Feature.without_tenant
    end

    # Retrieves features with a specific status.
    #
    # @param status [Symbol, String, Integer] The status to filter by.
    # @return [ActiveRecord::Relation] A relation of features with the given status.
    def with_status(status)
      Togglefy::Feature.with_status(status)
    end

    # Applies filters to retrieve features.
    #
    # @param filters [Hash] The filters to apply.
    # @return [ActiveRecord::Relation] A relation of features matching the filters.
    def for_filters(filters)
      FILTERS.reduce(Togglefy::Feature) do |query, (key, scope)|
        value = filters[key]
        next query unless filters.key?(key) && nil_or_not_blank?(value)

        query.public_send(scope, value)
      end
    end

    private

    # Checks if a value is nil or not blank.
    #
    # @param value [Symbol, String, Integer] The value to check.
    # @return [Boolean] True if the value is nil or not blank, false otherwise.
    def nil_or_not_blank?(value)
      value.nil? || !value.blank?
    end
  end
end
