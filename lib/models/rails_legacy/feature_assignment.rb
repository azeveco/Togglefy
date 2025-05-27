# frozen_string_literal: true

module Togglefy
  # Represents the assignment of a feature to an assignable entity.
  # A feature assignment links a feature to an assignable object, which can be of any polymorphic type.
  class FeatureAssignment < ActiveRecord::Base
    # Associations
    # @!attribute [rw] feature
    #   @return [Feature] The feature associated with this assignment.
    belongs_to :feature, class_name: "Togglefy::Feature"

    # @!attribute [rw] assignable
    #   @return [Object] The polymorphic assignable object associated with this assignment.
    belongs_to :assignable, polymorphic: true

    # Scopes
    # Finds feature assignments for a specific assignable type.
    # @param klass [Class] The class type of the assignable.
    # @return [ActiveRecord::Relation] The feature assignments for the given type.
    scope :for_type, ->(klass) { where(assignable_type: klass.to_s) }
  end
end
