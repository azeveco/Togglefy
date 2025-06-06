# frozen_string_literal: true

require "active_support/concern"

module Togglefy
  # The Assignable module provides functionality for models to relate with features.
  # It includes methods to add, remove, and query features, as well as ActiveRecord scopes.
  module Assignable
    extend ActiveSupport::Concern

    included do
      # Establishes a many-to-many relationship with features through feature assignments.
      has_many :feature_assignments, as: :assignable, class_name: "Togglefy::FeatureAssignment"
      has_many :features, through: :feature_assignments, class_name: "Togglefy::Feature"

      # Scope to retrieve assignables with specific features.
      #
      # @param feature_ids [Array<Integer>] The IDs of the features to filter by.
      scope :with_features, lambda { |feature_ids|
        joins(:feature_assignments)
          .where(feature_assignments: {
                   feature_id: feature_ids
                 })
          .distinct
      }

      # Scope to retrieve assignables without specific features.
      #
      # @param feature_ids [Array<Integer>] The IDs of the features to filter by.
      scope :without_features, lambda { |feature_ids|
        joins(left_join_on_features(feature_ids))
          .where("fa.id IS NULL")
          .distinct
      }
    end

    # Checks if the assignable has a specific feature or feature that depends on it.
    #
    # @param identifier [Symbol, String] The identifier of the feature.
    # @return [Boolean] True if the feature exists, false otherwise.
    def feature?(identifier)
      identifiers = Togglefy::FeatureDependencyLoader.features_depending_on(identifier)
      identifiers << identifier

      features.active.exists?(identifier: identifiers)
    end
    alias has_feature? feature?

    # Adds a feature to the assignable.
    #
    # @param feature [Togglefy::Feature, String] The feature or its identifier.
    def add_feature(feature)
      feature = find_feature!(feature)
      features << feature unless has_feature?(feature.identifier)
    end

    # Removes a feature from the assignable.
    #
    # @param feature [Togglefy::Feature, String] The feature or its identifier.
    def remove_feature(feature)
      feature = find_feature!(feature)
      features.destroy(feature) if has_feature?(feature.identifier)
    end

    # Clears all features from the assignable.
    def clear_features
      features.destroy_all
    end

    private

    # Finds a feature by its identifier or returns the feature if already provided.
    #
    # @param feature [Togglefy::Feature, String] The feature or its identifier.
    # @return [Togglefy::Feature] The found feature.
    def find_feature!(feature)
      return feature if feature.is_a?(Togglefy::Feature)

      Togglefy::Feature.find_by!(identifier: feature.to_s)
    end

    class_methods do
      # Generates a SQL LEFT JOIN clause for features.
      #
      # @param feature_ids [Array<Integer>] The IDs of the features to join on.
      # @return [String] The SQL LEFT JOIN clause.
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
