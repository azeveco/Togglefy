# frozen_string_literal: true

module Togglefy
  # The BulkToggler class provides functionality to enable or disable features
  # in bulk for assignables, such as users or accounts.
  class BulkToggler
    # List of allowed filters for assignables.
    ALLOWED_ASSIGNABLE_FILTERS = %i[group role environment env tenant_id].freeze

    # Initializes a new BulkToggler instance.
    #
    # @param klass [Class] The assignable class (e.g., User, Account).
    def initialize(klass)
      @klass = klass
    end

    # Enables features for assignables based on filters.
    # @note All parameters but the first (identifiers) should be passed as keyword arguments.
    #
    # @param identifiers [Array<String>, String] The feature identifiers to enable.
    # @param group [String] The group name to filter assignables by.
    # @param role [String] The role name to filter assignables by.
    # @param environment [String] The environment name to filter assignables by.
    # @param env [String] The environment name to filter assignables by.
    # @param tenant_id [String] The tenant_id to filter assignables by.
    # @param percentage [Integer] The percentage of assignables to include.
    def enable(identifiers, **filters)
      toggle(:enable, identifiers, filters)
      true
    end

    # Disables features for assignables based on filters.
    # @note All parameters but the first (identifiers) should be passed as keyword arguments.
    #
    # @param identifiers [Array<String>, String] The feature identifiers to disable.
    # @param group [String] The group name to filter assignables by.
    # @param role [String] The role name to filter assignables by.
    # @param environment [String] The environment name to filter assignables by.
    # @param env [String] The environment name to filter assignables by.
    # @param tenant_id [String] The tenant_id to filter assignables by.
    # @param percentage [Integer] The percentage of assignables to include.
    def disable(identifiers, **filters)
      toggle(:disable, identifiers, filters)
      true
    end

    private

    attr_reader :klass

    # Toggles features for assignables based on the action.
    #
    # @param action [Symbol] The action to perform (:enable or :disable).
    # @param identifiers [Array<String>, String] The feature identifiers.
    # @param filters [Hash] Additional filters for assignables.
    def toggle(action, identifiers, filters)
      identifiers = Array(identifiers)
      features = get_features(identifiers, filters)

      feature_ids = features.map(&:id)

      assignables = get_assignables(action, feature_ids)

      assignables = sample_assignables(assignables, filters[:percentage]) if filters[:percentage]

      enable_flow(assignables, features, identifiers) if action == :enable
      disable_flow(assignables, features, identifiers) if action == :disable
    end

    # Retrieves features based on identifiers and filters.
    #
    # @param identifiers [Array<String>] The feature identifiers.
    # @param filters [Hash] Additional filters for features.
    # @return [Array<Togglefy::Feature>] The matching features.
    # @raise [Togglefy::FeatureNotFound] If no features are found.
    def get_features(identifiers, filters)
      features = Togglefy.for_filters(filters: { identifier: identifiers }.merge(build_scope_filters(filters))).to_a

      raise Togglefy::FeatureNotFound if features.empty?

      features
    end

    # Retrieves assignables based on the action and feature IDs.
    #
    # @param action [Symbol] The action to perform (:enable or :disable).
    # @param feature_ids [Array<Integer>] The feature IDs.
    # @return [Array<Assignable>] The matching assignables.
    # @raise [Togglefy::AssignablesNotFound] If no assignables are found.
    def get_assignables(action, feature_ids)
      assignables = klass.without_features(feature_ids) if action == :enable
      assignables = klass.with_features(feature_ids) if action == :disable

      raise Togglefy::AssignablesNotFound, klass if assignables.empty?

      assignables
    end

    # Builds scope filters for assignables.
    #
    # @param filters [Hash] The filters to process.
    # @return [Hash] The processed filters.
    def build_scope_filters(filters)
      filters.slice(*ALLOWED_ASSIGNABLE_FILTERS).compact
    end

    # Samples assignables based on a percentage.
    #
    # @param assignables [Array<Assignable>] The assignables to sample.
    # @param percentage [Float] The percentage of assignables to include.
    # @return [Array<Assignable>] The sampled assignables.
    def sample_assignables(assignables, percentage)
      count = (assignables.size * percentage.to_f / 100).round
      assignables.sample(count)
    end

    # Enables features for assignables.
    #
    # @param assignables [Array<Assignable>] The assignables to update.
    # @param features [Array<Togglefy::Feature>] The features to enable.
    # @param identifiers [Array<String>] The feature identifiers.
    def enable_flow(assignables, features, identifiers)
      rows = []

      assignables.each do |assignable|
        features.each do |feature|
          rows << { assignable_id: assignable.id, assignable_type: assignable.class.name, feature_id: feature.id }
        end
      end

      mass_insert(rows, identifiers)
    end

    # Inserts feature assignments in bulk.
    #
    # @param rows [Array<Hash>] The rows to insert.
    # @param identifiers [Array<String>] The feature identifiers.
    # @raise [Togglefy::BulkToggleFailed] If the bulk insert fails.
    def mass_insert(rows, identifiers)
      return unless rows.any?

      ActiveRecord::Base.transaction do
        Rails::VERSION::MAJOR >= 6 ? Togglefy::FeatureAssignment.insert_all(rows) : insert_all(rows)
      end
    rescue Togglefy::Error => e
      raise Togglefy::BulkToggleFailed.new(
        "Bulk toggle enable failed for #{klass.name} with identifiers #{identifiers.inspect}",
        e
      )
    end

    def insert_all(rows)
      return if rows.empty?

      columns = rows.first.keys
      values = rows.map do |row|
        "(#{columns.map { |col| ActiveRecord::Base.connection.quote(row[col]) }.join(", ")}, #{ActiveRecord::Base.sanitize(Time.zone.now)}, #{ActiveRecord::Base.sanitize(Time.zone.now)})"
      end

      sql = insert_all_query(columns, values)

      ActiveRecord::Base.connection.execute(sql)
    end

    def insert_all_query(columns, values)
      <<-SQL.squish
        INSERT INTO togglefy_feature_assignments (#{columns.push(:created_at, :updated_at).join(", ")})
        VALUES #{values.join(", ")}
      SQL
    end

    # Disables features for assignables.
    #
    # @param assignables [Array<Assignable>] The assignables to update.
    # @param features [Array<Togglefy::Feature>] The features to disable.
    # @param identifiers [Array<String>] The feature identifiers.
    def disable_flow(assignables, features, identifiers)
      ids_to_remove = []

      assignables.each do |assignable|
        features.each do |feature|
          ids_to_remove << [assignable.id, feature.id]
        end
      end

      mass_delete(ids_to_remove, identifiers)
    end

    # Deletes feature assignments in bulk.
    #
    # @param ids_to_remove [Array<Array>] The IDs to remove.
    # @param identifiers [Array<String>] The feature identifiers.
    # @raise [Togglefy::BulkToggleFailed] If the bulk delete fails.
    def mass_delete(ids_to_remove, identifiers)
      return unless ids_to_remove.any?

      ActiveRecord::Base.transaction do
        Togglefy::FeatureAssignment.where(mass_delete_scope(ids_to_remove, klass.name)).delete_all
      end
    rescue Togglefy::Error => e
      raise Togglefy::BulkToggleFailed.new(
        "Bulk toggle disable failed for #{klass.name} with identifiers #{identifiers.inspect}",
        e
      )
    end

    # Builds the scope for mass deletion.
    #
    # @param ids [Array<Array>] The IDs of features to delete from the assignables.
    # @param klass_name [String] The class name of the assignable.
    # @return [Hash] The scope for mass deletion to be used in the query.
    def mass_delete_scope(ids, klass_name)
      {
        assignable_id: ids.map(&:first),
        assignable_type: klass_name,
        feature_id: ids.map(&:last)
      }
    end
  end
end
