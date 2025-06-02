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
#   #     feature: "dark_mode",
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
      @feature_data = fetch_feature_data
    end

    # Generates analytics data for the feature.
    #
    # @return [Array<Hash>] An array of hashes, each containing:
    #   - assignable type
    #   - feature identifier
    #   - counts of enabled/disabled
    #   - percentages
    #   - assignment metadata (created_at timestamps, activity windows)
    def track
      return [] unless @feature_data

      build_tracking_data
    end

    private

    # Attempts to fetch the feature data based on the identifier.
    #
    # @return [Togglefy::Feature, nil] The feature if found, else nil.
    def fetch_feature_data
      Togglefy::Feature.includes(feature_assignments: :assignable)
                       .find_by(identifier: @identifier)
    end

    # Builds the full tracking data array.
    #
    # @return [Array<Hash>] Tracking data for each assignable.
    def build_tracking_data
      @feature_data.feature_assignments.group_by(&:assignable_type).map do |assignable_type, assignments|
        assignable_class = safe_constantize(assignable_type)
        next unless assignable_class

        total_count = assignable_class.count
        enabled_count = assignments.count
        disabled_count = total_count - enabled_count

        assignable_data = assignables_data(enabled_count, disabled_count, total_count)
        assignments_data = build_assignments_data(assignments)

        [{ assignable: assignable_type, feature: @identifier }, assignable_data, assignments_data].reduce(:merge)
      end.compact
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
    # @param assignments [ActiveRecord::Relation] The feature assignment records.
    # @return [Hash] Assignment activity data.
    def build_assignments_data(assignments)
      # rubocop:disable Naming/VariableNumber
      {
        last_created: assignments.map(&:created_at).max || nil,
        first_created: assignments.map(&:created_at).min || nil,
        past_7: count_assignments_in(assignments, 7.days.ago),
        past_14: count_assignments_in(assignments, 14.days.ago),
        past_31: count_assignments_in(assignments, 31.days.ago)
      }
      # rubocop:enable Naming/VariableNumber
    end

    # Counts how many assignments occurred since a given date.
    #
    # @param period [Date, Time] Range period which the method will count the assignments.
    # @return [Integer] The number of assignments created since that date.
    def count_assignments_in(assignments, period)
      assignments.count { |a| a.created_at >= period } || 0
    end
  end
end
