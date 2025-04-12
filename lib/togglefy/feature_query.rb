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

    def for_filters(filters)
      Togglefy::Feature
        .for_group(filters[:group] || filters[:role])
        .for_environment(filters[:environment] || filters[:env])
        .for_tenant(filters[:tenant_id])
    end

    def with_status(status)
      Togglefy::Feature.with_status(status)
    end
  end
end