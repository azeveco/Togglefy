# frozen_string_literal: true

RSpec.describe Togglefy::Assignable, type: :model do
  describe "access" do
    let!(:assignable) { User.create }

    it ".has_feature? return truthy for feature who assigns and features dependencies" do
      feat_a = Togglefy::Feature.create!(name: "Feat A", identifier: :feat_a, status: :active)
      feat_b = Togglefy::Feature.create!(name: "Feat B", identifier: :feat_b, status: :active)
      feat_c = Togglefy::Feature.create!(name: "Feat C", identifier: :feat_c, status: :active)

      assignable.add_feature(feat_c.identifier)

      expect(assignable.has_feature?(feat_a.identifier)).to be_truthy
      expect(assignable.has_feature?(feat_b.identifier)).to be_truthy
      expect(assignable.has_feature?(feat_c.identifier)).to be_truthy
    end

    it ".has_feature? return truthy for feature without dependencies" do
      feat_a = Togglefy::Feature.create!(name: "feat_a", identifier: :feat_a, status: :active)

      assignable.add_feature(feat_a.identifier)

      expect(assignable.has_feature?(feat_a.identifier)).to be_truthy
    end
  end
end
