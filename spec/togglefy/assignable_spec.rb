# frozen_string_literal: true

RSpec.describe Togglefy::Assignable, type: :model do
  describe "access" do
    let!(:assignable) { User.new }

    it ".has_feature? return truthy for feature who assigns and features dependencies" do
      feat_1 = Togglefy::Feature.create!(name: "X", identifier: :x)
      feat_a = Togglefy::Feature.create!(name: "H", identifier: :h)

      assignable.add_feature(feat_a.identifier)
      assignable.add_feature(feat_1.identifier)

      expect(assignable.has_feature?(feat_1.identifier)).to be_truthy
    end

    it ".has_feature? return truthy for feature without dependencies" do
      feat_1 = Togglefy::Feature.create!(name: "X", identifier: :x)
      feat_a = Togglefy::Feature.create!(name: "H", identifier: :h)

      assignable.add_feature(feat_a.identifier)
      assignable.add_feature(feat_1.identifier)

      expect(assignable.has_feature?(feat_1.identifier)).to be_truthy
    end
  end
end
