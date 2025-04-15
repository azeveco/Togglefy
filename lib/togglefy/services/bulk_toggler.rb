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
      features = Togglefy.for_filters(
        filters: {identifier: identifiers}.merge(build_scope_filters(filters))
      ).to_a

      raise Togglefy::FeatureNotFound if features.empty?

      feature_ids = features.map(&:id)

      assignables = if action == :enable
        klass.without_features(feature_ids, filters)
      else
        klass.with_features(feature_ids, filters)
      end

      raise Togglefy::AssignablesNotFound.new(klass, identifiers, filters) if assignables.empty?
      
      assignables = sample_assignables(assignables, filters[:percentage]) if filters[:percentage]

      existing_assignments = Togglefy::FeatureAssignment.where(
        assignable_id: assignables.map(&:id),
        assignable_type: klass.name,
        feature_id: features.map(&:id)
      ).pluck(:assignable_id, :feature_id)

      existing_lookup = Set.new(existing_assignments)
      
      if action == :enable
        rows = []

        assignables.each do |assignable|
          features.each do |feature|
            key = [assignable.id, feature.id]
            next if existing_lookup.include?(key)

            rows << {
              assignable_id: assignable.id,
              assignable_type: assignable.class.name,
              feature_id: feature.id
            }
          end
        end

        begin
          Togglefy::FeatureAssignment.insert_all(rows) if rows.any?
        rescue => error
          raise Togglefy::BulkToggleFailed.new(
            "Bulk toggle enable failed for #{klass.name} with identifiers #{identifiers.inspect}",
            error
          )
        end
      elsif action == :disable
        ids_to_remove = []
        assignables.each do |assignable|
          features.each do |feature|
            key = [assignable.id, feature.id]
            ids_to_remove << key if existing_lookup.include?(key)
          end
        end

        begin
          if ids_to_remove.any?
            Togglefy::FeatureAssignment.where(
              assignable_id: ids_to_remove.map(&:first),
              assignable_type: klass.name,
              feature_id: ids_to_remove.map(&:last)
            ).delete_all
          end
        rescue => error
          raise Togglefy::BulkToggleFailed.new(
            "Bulk toggle disable failed for #{klass.name} with identifiers #{identifiers.inspect}",
            error
          )
        end
      end
    end

    def build_scope_filters(filters)
      filters.slice(*ALLOWED_ASSIGNABLE_FILTERS).compact
    end

    def sample_assignables(assignables, percentage)
      count = (assignables.size * percentage.to_f / 100).round
      assignables.sample(count)
    end
  end
end
