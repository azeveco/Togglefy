# frozen_string_literal: true

require "jane/version"
require "jane/engine"
require "jane/featureable"
require "jane/feature_manager"

module Jane
  class Error < StandardError; end
  
  def self.for(assignable)
    FeatureManager.new(assignable)
  end
end
