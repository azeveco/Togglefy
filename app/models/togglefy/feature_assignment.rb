# frozen_string_literal: true

if Rails::VERSION::MAJOR >= 7
  require_relative "models/rails_7/feature_assignment"
elsif Rails::VERSION::MAJOR >= 5
  require_relative "models/rails_5/feature_assignment"
else
  require_relative "models/rails_legacy/feature_assignment"
end
