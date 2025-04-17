# frozen_string_literal: true

RSpec.describe Togglefy::Feature, type: :model do
  describe "validations" do
    it "is valid with name and identifier" do
      feature = described_class.new(name: "Dark Mode", identifier: :dark_mode)
      expect(feature).to be_valid
    end

    it "is invalid without name" do
      feature = described_class.new(identifier: :missing_name)
      expect(feature).not_to be_valid
      expect(feature.errors[:name]).to include("can't be blank")
    end

    it "is invalid with duplicate identifier" do
      described_class.create!(name: "Dark Mode", identifier: :dark_mode)
      dup = described_class.new(name: "Dark Mode 2", identifier: :dark_mode)
      expect(dup).not_to be_valid
      expect(dup.errors[:identifier]).to include("has already been taken")
    end
  end

  describe "callbacks" do
    context "before_validation" do
      context "build_identifier" do
        it "generates identifier when name is present and identifier is null" do
          feature = described_class.create!(name: "Awesome feature")
          expect(feature.identifier.to_sym).to eq(:awesome_feature)
        end

        it "doesn't run when name and identifier are present" do
          feature = described_class.create!(name: "Mega feature",
                                            identifier: :identifier_unrelated_to_the_name_lol_this_is_big)
          expect(feature.identifier.to_sym).not_to eq(:mega_feature)
          expect(feature.identifier.to_sym).to eq(:identifier_unrelated_to_the_name_lol_this_is_big)
        end
      end
    end
  end

  describe "scopes" do
    let!(:active_feature)   { described_class.create!(name: "A", identifier: :a, status: :active) }
    let!(:inactive_feature) { described_class.create!(name: "B", identifier: :b, status: :inactive) }

    it ".identifier finds by one or many identifiers" do
      expect(described_class.identifier(:a)).to include(active_feature)
      expect(described_class.identifier(%i[a b])).to match_array([active_feature, inactive_feature])
    end

    it ".with_status returns correct features based on parameter" do
      expect(described_class.with_status(:active)).to include(active_feature)
      expect(described_class.with_status(:inactive)).to include(inactive_feature)
    end

    it ".active returns active features" do
      expect(described_class.active).to include(active_feature)
      expect(described_class.active).not_to include(inactive_feature)
    end

    it ".inactive returns inactive features" do
      expect(described_class.inactive).to include(inactive_feature)
      expect(described_class.inactive).not_to include(active_feature)
    end

    it ".for_group filters by group" do
      f1 = described_class.create!(name: "X", identifier: :x, group: :staff)
      f2 = described_class.create!(name: "Y", identifier: :y, group: :beta)
      expect(described_class.for_group(:staff)).to include(f1)
      expect(described_class.for_group(:staff)).not_to include(f2)
    end

    it ".without_group filters by features with no groups (nil)" do
      f1 = described_class.create!(name: "C", identifier: :c)
      f2 = described_class.create!(name: "D", identifier: :d, group: :admin)
      expect(described_class.without_group).to include(f1)
      expect(described_class.without_group).not_to include(f2)
    end

    it ".for_environment filters by environment" do
      f1 = described_class.create!(name: "G", identifier: :g, environment: :production)
      f2 = described_class.create!(name: "H", identifier: :h, environment: :staging)
      expect(described_class.for_environment(:production)).to include(f1)
      expect(described_class.for_environment(:production)).not_to include(f2)
    end

    it ".without_environment filters by features with no environments (nil)" do
      f1 = described_class.create!(name: "E", identifier: :e)
      f2 = described_class.create!(name: "F", identifier: :f, environment: :production)
      expect(described_class.without_environment).to include(f1)
      expect(described_class.without_environment).not_to include(f2)
    end

    it ".for_tenant filters by tenant_id" do
      f1 = described_class.create!(name: "T", identifier: :t, tenant_id: "123abc")
      f2 = described_class.create!(name: "U", identifier: :u, tenant_id: "abc123")
      expect(described_class.for_tenant("123abc")).to include(f1)
      expect(described_class.for_tenant("123abc")).not_to include(f2)
    end

    it ".without_tenant filters by features with no tenant_id (nil)" do
      f1 = described_class.create!(name: "E", identifier: :e)
      f2 = described_class.create!(name: "F", identifier: :f, tenant_id: "123abc")
      expect(described_class.without_tenant).to include(f1)
      expect(described_class.without_tenant).not_to include(f2)
    end
  end
end
