# frozen_string_literal: true

module Togglefy
  class FeatureAssignment < ApplicationRecord
    belongs_to :feature, class_name: "Togglefy::Feature"
    belongs_to :assignable, polymorphic: true

    scope :for_type, ->(klass) { where(assignable_type: klass.to_s) }
  end
end
