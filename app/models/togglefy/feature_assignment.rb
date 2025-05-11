# frozen_string_literal: true

module Togglefy
  class FeatureAssignment < ApplicationRecord
    belongs_to :feature, class_name: "Togglefy::Feature"
    belongs_to :assignable, polymorphic: true

    scope :for_type, ->(klass) { where(assignable_type: klass.to_s) }
    scope :feature, ->(feature_id) { where(feature_id: feature_id) }
  end
end
