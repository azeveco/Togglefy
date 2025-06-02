# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
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
        analytics = described_class.new(feature_identifier)

        expect(analytics.instance_variable_get(:@identifier)).to eq(feature_identifier)
        expect(analytics.instance_variable_get(:@feature_data)).to be_present
      end
    end
  end

  describe "#track" do
    before do
      user_one.add_feature(feature_identifier)
      user_two.add_feature(feature_identifier)

      # Create additional users without the feature
      3.times { User.create! }
    end

    context "when feature exists" do
      it "returns tracking data consistent" do
        result = described_class.new(feature_identifier).track

        expect(result).to be_an(Array)
        expect(result).not_to be_empty
        expect(result.first).to be_a(Hash)
      end

      it "returns tracking data correctly" do
        result = described_class.new(feature_identifier).track
        expect(result).not_to be_empty

        user_tracking = result.first
        expect(user_tracking[:assignable]).to eq("User")
        expect(user_tracking[:total]).to eq(5)
        expect(user_tracking[:enabled_count]).to eq(2)
        expect(user_tracking[:disabled_count]).to eq(3)
        expect(user_tracking[:percentage_enabled]).to eq("40.0%")
        expect(user_tracking[:percentage_disabled]).to eq("60.0%")
        expect(user_tracking[:last_created]).to be_an(Time)
        expect(user_tracking[:first_created]).to be_an(Time)
        # rubocop:disable Naming/VariableNumber
        expect(user_tracking[:past_7]).to eq(2)
        expect(user_tracking[:past_14]).to eq(2)
        expect(user_tracking[:past_31]).to eq(2)
        # rubocop:enable Naming/VariableNumber
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

    describe "#assignables_data" do
      it "builds assignable data correctly" do
        result = analytics.send(:assignables_data, 2, 3, 5)

        expect(result[:enabled_count]).to eq(2)
        expect(result[:disabled_count]).to eq(3)
        expect(result[:total]).to eq(5)
        expect(result[:percentage_enabled]).to eq("40.0%")
        expect(result[:percentage_disabled]).to eq("60.0%")
      end

      it "handles zero totals gracefully" do
        result = analytics.send(:assignables_data)

        expect(result[:enabled_count]).to eq(0)
        expect(result[:disabled_count]).to eq(0)
        expect(result[:total]).to eq(0)
        expect(result[:percentage_enabled]).to eq("0.00%")
        expect(result[:percentage_disabled]).to eq("0.00%")
      end
    end

    describe "#build_assignments_data" do
      let(:created_times) do
        [
          Time.current - 1.day,
          Time.current - 5.days,
          Time.current - 10.days,
          Time.current - 20.days
        ]
      end

      let(:mock_assignments) do
        created_times.map do |time|
          instance_double("Togglefy::FeatureAssignment", created_at: time)
        end
      end

      before do
        travel_to Time.new(2024, 12, 4, 16, 30) # Mon, 04 Dec 2024 16:30:00
      end

      it "builds assignments data correctly" do
        result = analytics.send(:build_assignments_data, mock_assignments)

        expect(result[:last_created]).to eq(created_times.first)
        expect(result[:first_created]).to eq(created_times.last)
        # rubocop:disable Naming/VariableNumber
        expect(result[:past_7]).to eq(2) # 1 day and 5 days ago
        expect(result[:past_14]).to eq(3) # 1, 5, and 10 days ago
        expect(result[:past_31]).to eq(4) # all assignments
        # rubocop:enable Naming/VariableNumber
      end

      it "handles empty assignments gracefully" do
        result = analytics.send(:build_assignments_data, [])

        expect(result[:last_created]).to be_nil
        expect(result[:first_created]).to be_nil
        # rubocop:disable Naming/VariableNumber
        expect(result[:past_7]).to eq(0)
        expect(result[:past_14]).to eq(0)
        expect(result[:past_31]).to eq(0)
        # rubocop:enable Naming/VariableNumber
      end
    end

    describe "#count_assignments_in" do
      let(:assignments) do
        [
          instance_double("Togglefy::FeatureAssignment", created_at: Time.current - 1.day),
          instance_double("Togglefy::FeatureAssignment", created_at: Time.current - 5.days),
          instance_double("Togglefy::FeatureAssignment", created_at: Time.current - 10.days),
          instance_double("Togglefy::FeatureAssignment", created_at: Time.current - 20.days)
        ]
      end

      before do
        travel_to Time.new(2024, 12, 4, 16, 30) # Mon, 04 Dec 2024 16:30:00
      end

      it "counts assignments correctly for different periods" do
        expect(analytics.send(:count_assignments_in, assignments, 7.days.ago)).to eq(2)
        expect(analytics.send(:count_assignments_in, assignments, 14.days.ago)).to eq(3)
        expect(analytics.send(:count_assignments_in, assignments, 31.days.ago)).to eq(4)
      end

      it "returns 0 for empty assignments" do
        expect(analytics.send(:count_assignments_in, [], 7.days.ago)).to eq(0)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
