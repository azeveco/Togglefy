module Jane
  class FeatureAssignment < ApplicationRecord
    belongs_to :feature, class_name: "Jane::Feature"
    belongs_to :assignable, polymorphic: true
  end
end