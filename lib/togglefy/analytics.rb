# frozen_string_literal: true

module Togglefy
  # maybe transform this Analytics class into a Module that
  # encapsulates wether we want to track: feature data or assignable data
  class Analytics
    def initialize(identifier = nil)
      @identifier = identifier unless identifier.nil?
      @feature = Togglefy.feature(@identifier)
    end

    def track
      build_tracking_data
    end

    def assignments
      Togglefy::FeatureAssignment.where(feature_id: @feature.id)
    end

    def assignables
      assignments.map(&:assignable_type).uniq
    end

    def build_tracking_data
      assignables.map do |assignable|
        assignable_data = build_assignable_data(assignable)
        assignments_data = build_assignments_data

        puts "assignable_data: #{assignable_data}"
        puts "assignments_data: #{assignments_data}"

        {
          assignable: assignable,
          total: assignable_data[:total_count],
          enabled_count: assignable_data[:with_features].count,
          disabled_count: assignable_data[:without_features].count,
          percentage_enabled: assignable_data[:with_feature_percentage],
          percentage_disabled: assignable_data[:without_feature_percentage],
          first_created: assignments_data[:first_created],
          last_created: assignments_data[:last_created],
          past7: assignments_data[:past7],
          past14: assignments_data[:past14],
          past30: assignments_data[:past30]
        }
      end
    end

    def build_assignable_data(assignable)
      klass = assignable.constantize
      with_features = klass.with_features(@feature.id)
      without_features = klass.without_features(@feature.id)
      total_count = with_features.count + without_features.count

      {
        with_features: with_features,
        without_features: without_features,
        total_count: total_count,
        with_feature_percentage: "#{(with_features.count.to_f / total_count.to_f * 100).truncate(2)}%",
        without_feature_percentage: "#{(without_features.count.to_f / total_count.to_f * 100).truncate(2)}%"
      }
    end

    def build_assignments_data
      {
        last_created: assignments.last.created_at,
        first_created: assignments.first.created_at,
        past7: assignments.where(created_at: 7.days.ago..Time.current).count,
        past14: assignments.where(created_at: 14.days.ago..Time.current).count,
        past30: assignments.where(created_at: 30.days.ago..Time.current).count
      }
    end
  end
end
