module Togglefy
  class FeatureQuery
    def feature(identifier)
      Togglefy::Feature.find_by!(identifier:)
    end

    def destroy_feature(identifier)
      feature = Togglefy::Feature.find_by!(identifier:)
      feature&.destroy
    end

    def for_type(klass)
      Togglefy::FeatureAssignment.for_type(klass)
    end

    def for_group(group)
      Togglefy::Feature.for_group(group)
    end
    alias :for_role :for_group

    def without_group
      Togglefy::Feature.without_group
    end
    alias :without_role :without_group

    def for_environment(environment)
      Togglefy::Feature.for_environment(environment)
    end
    alias :for_env :for_environment

    def without_environment
      Togglefy::Feature.without_environment
    end
    alias :without_env :without_environment

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
      Togglefy::Feature
        .then { |q| safe_chain(q, :identifier, filters[:identifier], apply_if: filters.key?(:identifier)) }
        .then { |q| safe_chain(q, :for_group, filters[:group] || filters[:role], apply_if: filters.key?(:group) || filters.key?(:role)) }
        .then { |q| safe_chain(q, :for_environment, filters[:environment] || filters[:env], apply_if: filters.key?(:environment) || filters.key?(:env)) }
        .then { |q| safe_chain(q, :for_tenant, filters[:tenant_id], apply_if: filters.key?(:tenant_id)) }
        .then { |q| safe_chain(q, :with_status, filters[:status], apply_if: filters.key?(:status)) }
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