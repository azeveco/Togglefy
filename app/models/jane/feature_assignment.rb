module Jane
  class FeatureAssignment < ApplicationRecord
    belongs_to :feature, class_name: "Jane::Feature"
    belongs_to :assignable, polymorphic: true

    scope :for_type, ->(klass) { where(assignable_type: klass.to_s) }
  end
end