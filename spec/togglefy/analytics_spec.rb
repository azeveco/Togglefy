# frozen_string_literal: true

require "rails_helper"

RSpec.describe Togglefy::Analytics do
  let!(:feature_identifier) { :test_feature }
  let!(:feature) { Togglefy::Feature.create!(name: "Test Feature", identifier: feature_identifier, status: :active) }
  let!(:analytics) { described_class.new(feature_identifier) }
  let!(:user_one) { User.create! }
  let!(:user_two) { User.create! }
  let!(:user_class) { User }

  describe "#initialize" do
    context "with valid identifier" do
      it "sets the identifier and fetches the feature" do
        expect(Togglefy).to receive(:feature).with(feature_identifier)
        described_class.new(feature_identifier)
      end
    end
  end

  describe "#track" do
    before do
      user_one.add_feature(feature_identifier)
      user_two.add_feature(feature_identifier)
      3.times { User.create! }
    end

    context "when feature exists" do
      it "returns tracking data consistent" do
        result = analytics.track
        expect(result).to be_an(Array)
        expect(result.first).to be_an(Hash)
      end

      it "returns tracking data correctly" do
        result = analytics.track
        user_tracking = result.first

        expect(user_tracking[:assignable]).to eq("User")
        expect(user_tracking[:total]).to eq(5)
        expect(user_tracking[:enabled_count]).to eq(2)
        expect(user_tracking[:disabled_count]).to eq(3)
        expect(user_tracking[:percentage_enabled]).to eq("40.0%")
        expect(user_tracking[:percentage_disabled]).to eq("60.0%")
        expect(user_tracking[:last_created]).to be_an(Time)
        expect(user_tracking[:first_created]).to be_an(Time)
        expect(user_tracking[:past7]).to eq(2)
        expect(user_tracking[:past14]).to eq(2)
        expect(user_tracking[:past30]).to eq(2)
      end
    end
  end

  describe "private methods" do
    describe "#safe_constantize" do
      it "successfully constantizes valid class names" do
        result = analytics.send(:safe_constantize, "User")
        expect(result).to eq(user_class)
      end

      it "handles invalid class names gracefully" do
        allow(Rails.logger).to receive(:warn)

        result = analytics.send(:safe_constantize, "InvalidClass")
        expect(result).to be_nil
        expect(Rails.logger).to have_received(:warn).with(/Invalid assignable class: InvalidClass/)
      end
    end

    describe "#build_assignables_data" do
      before do
        user_one.add_feature(feature_identifier)
        user_two.add_feature(feature_identifier)
        3.times { User.create! }
      end

      it "builds assignable data correctly" do
        result = analytics.send(:build_assignables_data, user_class)

        expect(result[:enabled_count]).to eq(2)
        expect(result[:disabled_count]).to eq(3)
        expect(result[:total_count]).to eq(5)
        expect(result[:percentage_enabled]).to eq("40.0%")
        expect(result[:percentage_disabled]).to eq("60.0%")
      end

      context "when assignable doesnt respond to Togglefy methods" do
        before do
          allow(user_class).to receive(:respond_to?).with(:with_features).and_return(false)
        end

        it "returns default assignable data" do
          result = analytics.send(:build_assignables_data, user_class)

          expect(result[:enabled_count]).to eq(0)
          expect(result[:disabled_count]).to eq(0)
          expect(result[:total_count]).to eq(0)
          expect(result[:percentage_enabled]).to eq("0.00%")
          expect(result[:percentage_disabled]).to eq("0.00%")
        end
      end
    end

    describe "#build_assignments_data" do
      let(:mock_assignments) { double("ActiveRecord::Relation") }
      let(:past7_assignments) { double("Relation", count: 3) }
      let(:past14_assignments) { double("Relation", count: 7) }
      let(:past30_assignments) { double("Relation", count: 15) }

      before do
        travel_to Time.new(2024, 12, 4, 16, 30) # Mon, 04 Dec 2024 16:30:00

        allow(analytics).to receive(:assignments).and_return(mock_assignments)
        allow(mock_assignments).to receive(:empty?).and_return(false)
        allow(mock_assignments).to receive(:maximum).with(:created_at).and_return(1.day.ago)
        allow(mock_assignments).to receive(:minimum).with(:created_at).and_return(30.days.ago)

        allow(mock_assignments).to receive(:where)
          .with(created_at: 7.days.ago..Time.current)
          .and_return(past7_assignments)
        allow(mock_assignments).to receive(:where)
          .with(created_at: 14.days.ago..Time.current)
          .and_return(past14_assignments)
        allow(mock_assignments).to receive(:where)
          .with(created_at: 30.days.ago..Time.current)
          .and_return(past30_assignments)
      end

      it "builds assignments data correctly" do
        result = analytics.send(:build_assignments_data)

        expect(result[:last_created]).to eq(1.day.ago)
        expect(result[:first_created]).to eq(30.days.ago)
        expect(result[:past7]).to eq(15)
        expect(result[:past14]).to eq(15)
        expect(result[:past30]).to eq(15)
      end
    end
  end
end
