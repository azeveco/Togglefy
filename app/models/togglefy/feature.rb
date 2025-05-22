# frozen_string_literal: true

if Rails::VERSION::MAJOR >= 7
  require_relative "models/rails_7/feature"
elsif Rails::VERSION::MAJOR >= 5
  require_relative "models/rails_5/feature"
else
  require_relative "models/rails_legacy/feature"
end
