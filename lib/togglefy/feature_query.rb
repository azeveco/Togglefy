# frozen_string_literal: true

module Togglefy
  class FeatureQuery
    FILTERS = {
      identifier: :identifier,
      group: :for_group,
      role: :for_group,
      environment: :for_environment,
      env: :for_environment,
      tenant_id: :for_tenant,
      status: :with_status
    }.freeze

    def features
      Togglefy::Feature.all
    end

    def feature(identifier)
      return Togglefy::Feature.identifier(identifier) if identifier.is_a?(Array)

      Togglefy::Feature.find_by!(identifier:)
    end

    def for_type(klass)
      Togglefy::FeatureAssignment.for_type(klass)
    end

    def for_group(group)
      Togglefy::Feature.for_group(group)
    end

    def without_group
      Togglefy::Feature.without_group
    end

    def for_environment(environment)
      Togglefy::Feature.for_environment(environment)
    end

    def without_environment
      Togglefy::Feature.without_environment
    end

    def for_tenant(tenant_id)
      Togglefy::Feature.for_tenant(tenant_id)
    end

    def without_tenant
      Togglefy::Feature.without_tenant
    end

    def with_status(status)
      Togglefy::Feature.with_status(status)
    end

    def for_filters(filters)
      FILTERS.reduce(Togglefy::Feature) do |query, (key, scope)|
        value = filters[key]
        next query unless filters.key?(key) && nil_or_not_blank?(value)

        query.public_send(scope, value)
      end
    end

    private

    def safe_chain(query, method, value, apply_if: true)
      apply_if && nil_or_not_blank?(value) ? query.public_send(method, value) : query
    end

    def nil_or_not_blank?(value)
      value.nil? || !value.blank?
    end
  end
end
