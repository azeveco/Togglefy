module Togglefy
  class FeatureManager
    def initialize(assignable)
      @assignable = assignable
    end

    def enable(feature)
      assignable.add_feature(feature)
      self
    end

    def disable(feature)
      assignable.remove_feature(feature)
      self
    end

    def clear(name = nil)
      if name
        assignable.remove_feature(name)
      else
        assignable.clear_features
      end
      self
    end

    def has?(feature)
      assignable.has_feature?(feature)
    end

    private

    attr_reader :assignable
  end
end
