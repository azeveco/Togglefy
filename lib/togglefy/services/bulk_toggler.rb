# frozen_string_literal: true

module Togglefy
  class BulkToggler
    ALLOWED_ASSIGNABLE_FILTERS = %i[group role environment env tenant_id].freeze

    def initialize(klass)
      @klass = klass
    end

    def enable(identifiers, **filters)
      toggle(:enable, identifiers, filters)
    end

    def disable(identifiers, **filters)
      toggle(:disable, identifiers, filters)
    end

    private

    attr_reader :klass

    def toggle(action, identifiers, filters)
      identifiers = Array(identifiers)
      features = get_features(identifiers, filters)

      feature_ids = features.map(&:id)

      assignables = get_assignables(action, feature_ids)

      assignables = sample_assignables(assignables, filters[:percentage]) if filters[:percentage]

      enable_flow(assignables, features, identifiers) if action == :enable
      disable_flow(assignables, features, identifiers) if action == :disable
    end

    def get_features(identifiers, filters)
      features = Togglefy.for_filters(filters: { identifier: identifiers }.merge(build_scope_filters(filters))).to_a

      raise Togglefy::FeatureNotFound if features.empty?

      features
    end

    def get_assignables(action, feature_ids)
      assignables = klass.without_features(feature_ids) if action == :enable
      assignables = klass.with_features(feature_ids) if action == :disable

      raise Togglefy::AssignablesNotFound, klass if assignables.empty?

      assignables
    end

    def build_scope_filters(filters)
      filters.slice(*ALLOWED_ASSIGNABLE_FILTERS).compact
    end

    def sample_assignables(assignables, percentage)
      count = (assignables.size * percentage.to_f / 100).round
      assignables.sample(count)
    end

    def enable_flow(assignables, features, identifiers)
      rows = []

      assignables.each do |assignable|
        features.each do |feature|
          rows << { assignable_id: assignable.id, assignable_type: assignable.class.name, feature_id: feature.id }
        end
      end

      mass_insert(rows, identifiers)
    end

    def mass_insert(rows, identifiers)
      Togglefy::FeatureAssignment.insert_all(rows) if rows.any?
    rescue Togglefy::Error => e
      raise Togglefy::BulkToggleFailed.new(
        "Bulk toggle enable failed for #{klass.name} with identifiers #{identifiers.inspect}",
        e
      )
    end

    def disable_flow(assignables, features, identifiers)
      ids_to_remove = []

      assignables.each do |assignable|
        features.each do |feature|
          ids_to_remove << [assignable.id, feature.id]
        end
      end

      mass_delete(ids_to_remove, identifiers)
    end

    def mass_delete(ids_to_remove, identifiers)
      if ids_to_remove.any?
        Togglefy::FeatureAssignment.where(
          assignable_id: ids_to_remove.map(&:first), assignable_type: klass.name, feature_id: ids_to_remove.map(&:last)
        ).delete_all
      end
    rescue Togglefy::Error => e
      raise Togglefy::BulkToggleFailed.new(
        "Bulk toggle disable failed for #{klass.name} with identifiers #{identifiers.inspect}",
        e
      )
    end
  end
end
