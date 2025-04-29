# frozen_string_literal: true

module Togglefy
  class Feature < ApplicationRecord
    enum :status, %i[inactive active]

    has_many :feature_assignments, dependent: :destroy
    has_many :assignables, through: :feature_assignments, source: :assignable

    before_validation :build_identifier, if: proc { |f| f.name.present? && f.identifier.blank? }

    scope :identifier, ->(identifier) { where(identifier:) }

    scope :for_group, ->(group) { where(group:) }
    scope :without_group, -> { where(group: nil) }

    scope :for_environment, ->(environment) { where(environment:) }
    scope :without_environment, -> { where(environment: nil) }

    scope :for_tenant, ->(tenant_id) { where(tenant_id:) }
    scope :without_tenant, -> { where(tenant_id: nil) }

    scope :inactive, -> { where(status: :inactive) }
    scope :active, -> { where(status: :active) }
    scope :with_status, ->(status) { where(status:) }

    validates :name, :identifier, presence: true, uniqueness: true

    private

    def build_identifier
      self.identifier = name.underscore.parameterize(separator: "_")
    end
  end
end
