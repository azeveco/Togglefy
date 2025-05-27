# frozen_string_literal: true

ROOT_PATH = "../../.."

if Rails::VERSION::MAJOR >= 7
  require_relative "#{ROOT_PATH}/lib/models/rails_7/feature"
elsif Rails::VERSION::MAJOR >= 5
  require_relative "#{ROOT_PATH}/lib/models/rails_5/feature"
else
  require_relative "#{ROOT_PATH}/lib/models/rails_legacy/feature"
end
