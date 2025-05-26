# frozen_string_literal: true

# This module provides analytics functionality for the Togglefy gem.
# It analyzes feature usage and assignment data, offering insights such as:
# - How many assignables have the feature enabled/disabled
# - Percentage breakdowns
# - Assignment activity over time
#
# @example
#   analytics = Togglefy::Analytics.new('dark_mode')
#   data = analytics.track
#   # => [
#   #   {
#   #     assignable: "User",
#   #     enabled_count: 120,
#   #     disabled_count: 30,
#   #     total_count: 150,
#   #     percentage_enabled: "80.0%",
#   #     percentage_disabled: "20.0%",
#   #     last_created: ...,
#   #     ...
#   #   }
#   # ]
module Togglefy
  class Analytics
    # Initializes the analytics with a feature identifier.
    #
    # @param identifier [String, Symbol, nil] The unique feature identifier.
    def initialize(identifier = nil)
      @identifier = identifier
      @feature = fetch_feature
    end

    # Generates analytics data for the feature.
    #
    # @return [Array<Hash>] An array of hashes, each containing:
    #   - assignable type
    #   - counts of enabled/disabled
    #   - percentages
    #   - assignment metadata (created_at timestamps, activity windows)
    def track
      return [] unless @feature

      build_tracking_data
    end

    private

    # Attempts to fetch the feature based on the identifier.
    #
    # @return [Togglefy::Feature, nil] The feature if found, else nil.
    def fetch_feature
      Togglefy.feature(@identifier) || nil
    end

    # Builds the full tracking data array.
    #
    # @return [Array<Hash>] Tracking data for each assignable.
    def build_tracking_data
      assignables.map do |assignable|
        assignable_class = safe_constantize(assignable)
        next unless assignable_class

        assignable_data = build_assignables_data(assignable_class)
        assignments_data = build_assignments_data

        [{ assignable: assignable, feature: @identifier }, assignable_data, assignments_data].reduce(:merge)
      end
    end

    # Returns a list of assignable class names related to the feature.
    #
    # @return [Array<String>] The list of assignable types (e.g., ["User", "Admin"]).
    def assignables
      @assignables ||= assignments.map(&:assignable_type).uniq
    end

    # Returns all assignments for the current feature.
    #
    # @return [ActiveRecord::Relation] The assignment records (enabled/disabled toggles).
    def assignments
      @assignments ||= @feature ? Togglefy::FeatureAssignment.where(feature_id: @feature.id) : []
    end

    # Safely converts a string class name to a constant.
    #
    # @param assignable [String] The name of the assignable class.
    # @return [Class, nil] The constantized class, or nil if invalid.
    def safe_constantize(assignable)
      assignable.constantize
    rescue NameError => e
      Rails.logger.warn("Invalid assignable class: #{assignable} - #{e.message}")
      nil
    end

    # Builds metrics for how the feature is distributed across assignables.
    #
    # @param klass [Class] The assignable class.
    # @return [Hash] Count and percentage breakdown.
    def build_assignables_data(klass)
      return assignables_data unless klass.respond_to?(:with_features) && klass.respond_to?(:without_features)

      with_features = klass.with_features(@feature.id)
      without_features = klass.without_features(@feature.id)

      enabled_count = with_features.count
      disabled_count = without_features.count
      total_count = enabled_count + disabled_count

      return assignables_data if total_count.zero?

      assignables_data(enabled_count, disabled_count, total_count)
    end

    # Builds a base hash of assignment data counts and percentages.
    #
    # @param enabled_count [Integer] Number of enabled assignments.
    # @param disabled_count [Integer] Number of disabled assignments.
    # @param total [Integer] Total number of assignments.
    # @return [Hash] A data hash with counts and formatted percentages.
    def assignables_data(enabled_count = 0, disabled_count = 0, total = 0)
      {
        enabled_count: enabled_count,
        disabled_count: disabled_count,
        total: total,
        percentage_enabled: calculate_percentage(enabled_count, total),
        percentage_disabled: calculate_percentage(disabled_count, total)
      }
    end

    # Calculates the percentage value based on count and total.
    #
    # @param count [Integer] The number of matching items (e.g., enabled assignments).
    # @param total [Integer] The total number of items.
    # @return [String] The percentage formatted as a string (e.g., "66.7%").
    def calculate_percentage(count, total)
      return "0.00%" if total.zero?

      percentage = (count.to_f / total * 100).round(2)
      "#{percentage}%"
    end

    # Builds time-based metrics for feature assignment activity.
    #
    # @return [Hash] Assignment activity data.
    def build_assignments_data
      return default_assignments_data if assignments.empty?

      # rubocop:disable Naming/VariableNumber
      {
        last_created: assignments.maximum(:created_at),
        first_created: assignments.minimum(:created_at),
        past_7: count_assignments_in_period(7.days.ago),
        past_14: count_assignments_in_period(14.days.ago),
        past_30: count_assignments_in_period(30.days.ago)
      }
      # rubocop:enable Naming/VariableNumber
    end

    # Counts how many assignments occurred since a given date.
    #
    # @param start_date [Date, Time] The starting date for the activity window.
    # @return [Integer] The number of assignments created since that date.
    def count_assignments_in_period(start_date)
      assignments.where(created_at: start_date..Time.current).count
    end

    # Returns default assignment tracking data for a feature.
    #
    # @return [Hash] A hash with default values for assignment metrics.
    def default_assignments_data
      {
        last_created: nil,
        first_created: nil,
        past7: 0,
        past14: 0,
        past30: 0
      }
    end
  end
end
