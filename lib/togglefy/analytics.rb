# frozen_string_literal: true

module Togglefy
  class Analytics
    def initialize(identifier = nil)
      @identifier = identifier
      @feature = fetch_feature
    end

    def track
      return [] unless @feature

      build_tracking_data
    end

    private

    def fetch_feature
      Togglefy.feature(@identifier) || nil
    end

    def build_tracking_data
      assignables.filter_map do |assignable|
        assignable_class = safe_constantize(assignable)
        next unless assignable_class

        assignable_data = build_assignables_data(assignable_class)
        assignments_data = build_assignments_data

        {
          assignable: assignable,
          total: assignable_data[:total_count],
          enabled_count: assignable_data[:enabled_count],
          disabled_count: assignable_data[:disabled_count],
          percentage_enabled: assignable_data[:percentage_enabled],
          percentage_disabled: assignable_data[:percentage_disabled],
          first_created: assignments_data[:first_created],
          last_created: assignments_data[:last_created],
          past7: assignments_data[:past7],
          past14: assignments_data[:past14],
          past30: assignments_data[:past30]
        }
      end
    end

    def assignables
      @assignables ||= assignments.map(&:assignable_type).uniq
    end

    def assignments
      @assignments ||= @feature ? Togglefy::FeatureAssignment.where(feature_id: @feature.id) : []
    end

    def safe_constantize(assignable)
      assignable.constantize
    rescue NameError => e
      Rails.logger.warn("Invalid assignable class: #{assignable} - #{e.message}")
      nil
    end

    def build_assignables_data(klass)
      return default_assignable_data unless klass.respond_to?(:with_features) && klass.respond_to?(:without_features)

      with_features = klass.with_features(@feature.id)
      without_features = klass.without_features(@feature.id)

      enabled_count = with_features.count
      disabled_count = without_features.count
      total_count = enabled_count + disabled_count

      return default_assignable_data if total_count.zero?

      {
        enabled_count: enabled_count,
        disabled_count: disabled_count,
        total_count: total_count,
        percentage_enabled: calculate_percentage(enabled_count, total_count),
        percentage_disabled: calculate_percentage(disabled_count, total_count)
      }
    end

    def default_assignable_data
      {
        enabled_count: 0,
        disabled_count: 0,
        total_count: 0,
        percentage_enabled: "0.00%",
        percentage_disabled: "0.00%"
      }
    end

    def calculate_percentage(count, total)
      return "0.00%" if total.zero?

      percentage = (count.to_f / total.to_f * 100).round(2)
      "#{percentage}%"
    end

    def build_assignments_data
      return default_assignments_data if assignments.empty?

      {
        last_created: assignments.maximum(:created_at),
        first_created: assignments.minimum(:created_at),
        past7: count_assignments_in_period(7.days.ago),
        past14: count_assignments_in_period(14.days.ago),
        past30: count_assignments_in_period(30.days.ago)
      }
    end

    def count_assignments_in_period(start_date)
      assignments.where(created_at: start_date..Time.current).count
    end

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
