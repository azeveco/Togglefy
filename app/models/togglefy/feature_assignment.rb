# frozen_string_literal: true

ROOT_PATH = "../../.."

if Rails::VERSION::MAJOR >= 7
  require_relative "#{ROOT_PATH}/lib/models/rails_7/feature_assignment"
elsif Rails::VERSION::MAJOR >= 5
  require_relative "#{ROOT_PATH}/lib/models/rails_5/feature_assignment"
else
  require_relative "#{ROOT_PATH}/lib/models/rails_legacy/feature_assignment"
end
