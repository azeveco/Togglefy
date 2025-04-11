module Jane
  class Feature < ApplicationRecord
    has_many :feature_assignments, dependent: :destroy
    has_many :assignables, through: :feature_assignments, source: :assignable

    before_create :build_identifier

    private

    def build_identifier
      self.identifier = self.name.snakecase
    end
  end
end