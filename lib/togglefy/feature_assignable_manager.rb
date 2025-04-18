# frozen_string_literal: true

module Togglefy
  class FeatureAssignableManager
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

    def clear
      assignable.clear_features
      self
    end

    def has?(feature)
      assignable.has_feature?(feature)
    end

    private

    attr_reader :assignable
  end
end
