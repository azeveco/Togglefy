# lib/jane/feature_manager.rb
module Jane
  class FeatureManager
    def initialize(assignable)
      @assignable = assignable
    end

    def enable(feature)
      assignable.add_feature(feature)
    end

    def disable(feature)
      assignable.remove_feature(feature)
    end

    def clear
      assignable.clear_features
    end

    def has?(feature)
      assignable.has_feature?(feature)
    end

    private

    attr_reader :assignable
  end
end
