module Jane
  class Feature < ApplicationRecord
    has_many :feature_assignments, dependent: :destroy
    has_many :assignables, through: :feature_assignments, source: :assignable

    validates :name, :identifier, presence: true, uniqueness: true

    before_validation :build_identifier

    private

    def build_identifier
      self.identifier = self.name.underscore.parameterize(separator: '_')
    end
  end
end