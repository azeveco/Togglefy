module Jane
  class FeatureQuery
    def feature(identifier)
      Jane::Feature.find_by!(identifier:)
    end

    def destroy_feature(identifier)
      feature = Jane::Feature.find_by!(identifier:)
      feature&.destroy
    end

    def for_type(klass)
      Jane::FeatureAssignment.for_type(klass)
    end

    def for_group(group)
      Jane::Feature.for_group(group)
    end
    alias :for_role :for_group

    def without_group(group)
      Jane::Feature.without_group(group)
    end
    alias :without_role :without_group

    def for_environment(env)
      Jane::Feature.for_environment(env)
    end
    alias :for_env :for_environment

    def without_environment(env)
      Jane::Feature.without_environment(env)
    end
    alias :without_env :without_environment

    def for_tenant(tenant_id)
      Jane::Feature.for_tenant(tenant_id)
    end

    def without_tenant(tenant_id)
      Jane::Feature.without_tenant(tenant_id)
    end

    def for_filters(filters)
      Jane::Feature
        .for_group(filters[:group] || filters[:role])
        .for_environment(filters[:environment] || filters[:env])
        .for_tenant(filters[:tenant_id])
    end
  end
end