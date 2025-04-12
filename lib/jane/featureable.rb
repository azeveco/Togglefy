module Jane
  module Featureable
    extend ActiveSupport::Concern

    included do
      has_many :feature_assignments, as: :assignable, class_name: "Jane::FeatureAssignment"
      has_many :features, through: :feature_assignments, class_name: "Jane::Feature"
    end

    def has_feature?(identifier)
      features.exists?(identifier: identifier.to_s)
    end

    def add_feature(feature)
      feature = find_feature!(feature)
      features << feature unless has_feature?(feature.identifier)
    end

    def remove_feature(feature)
      feature = find_feature!(feature)
      features.destroy(feature) if has_feature?(feature.identifier)
    end

    def clear_features
      features.destroy_all
    end

    private

    def find_feature!(feature)
      return feature if feature.is_a?(Jane::Feature)

      Jane::Feature.find_by!(identifier: feature.to_s)
    end
  end
end