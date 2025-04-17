# frozen_string_literal: true

module Togglefy
  class FeatureManager
    def initialize(identifier = nil)
      @identifier = identifier unless identifier.nil?
    end

    def create(**params)
      Togglefy::Feature.create!(**params)
    end

    def update(**params)
      feature.update!(**params)
    end

    def destroy
      feature.destroy
    end

    def toggle
      return feature.inactive! if feature.active?

      feature.active!
    end

    def active!
      feature.active!
    end

    def inactive!
      feature.inactive!
    end

    private

    attr_reader :identifier

    def feature
      Togglefy::Feature.find_by!(identifier:)
    end
  end
end
