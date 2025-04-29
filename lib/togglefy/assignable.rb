# frozen_string_literal: true

require "active_support/concern"

module Togglefy
  module Assignable
    extend ActiveSupport::Concern

    included do
      has_many :feature_assignments, as: :assignable, class_name: "Togglefy::FeatureAssignment"
      has_many :features, through: :feature_assignments, class_name: "Togglefy::Feature"

      scope :with_features, lambda { |feature_ids|
        joins(:feature_assignments)
          .where(feature_assignments: {
                   feature_id: feature_ids
                 })
          .distinct
      }

      scope :without_features, lambda { |feature_ids|
        joins(left_join_on_features(feature_ids))
          .where("fa.id IS NULL")
          .distinct
      }
    end

    def feature?(identifier)
      features.exists?(identifier: identifier.to_s)
    end
    alias has_feature? feature?

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
      return feature if feature.is_a?(Togglefy::Feature)

      Togglefy::Feature.find_by!(identifier: feature.to_s)
    end

    class_methods do
      def left_join_on_features(feature_ids)
        table = table_name
        type = name

        <<~SQL.squish
          LEFT JOIN togglefy_feature_assignments fa
            ON fa.assignable_id = #{table}.id
            AND fa.assignable_type = '#{type}'
            AND fa.feature_id IN (#{Array(feature_ids).join(",")})
        SQL
      end
    end
  end
end
