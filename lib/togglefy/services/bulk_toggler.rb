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

      features = Togglefy.for_filters(filters: {identifier: identifiers}).to_a

      assignables = klass.where(build_scope_filters(filters)) # TODO: Get only the ones that do/don't already have the feature

      if filters[:percentage]
        count = (assignables.size * filters[:percentage].to_f / 100).round
        assignables = assignables.sample(count)
      end

      assignables.each do |assignable|
        manager = Togglefy.for(assignable)
        features.each do |feature|
          action == :enable ? manager.enable(feature.identifier) : manager.disable(feature.identifier)
        end
      end
    end

    def build_scope_filters(filters)
      filters.slice(*ALLOWED_ASSIGNABLE_FILTERS).compact
    end
  end
end
