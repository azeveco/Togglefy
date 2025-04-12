module Jane
  class Feature < ApplicationRecord
    enum :status, [ :inactive, :active ]
    
    has_many :feature_assignments, dependent: :destroy
    has_many :assignables, through: :feature_assignments, source: :assignable

    before_validation :build_identifier

    scope :for_group, ->(group) { where(group: group) }
    scope :without_group, -> { where(group: nil) }

    scope :for_environment, ->(env) { where(environment: env) }
    scope :without_environment, -> { where(environment: nil) }

    scope :for_tenant, ->(tenant_id) { where(tenant: tenant_id) }
    scope :without_tenant, -> { where(tenant: nil) }

    validates :name, :identifier, presence: true, uniqueness: true

    private

    def build_identifier
      self.identifier = self.name.underscore.parameterize(separator: '_')
    end
  end
end