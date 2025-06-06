module Togglefy
  # The FeatureDependencyLoader class provides methods to manage features dependencies
  class FeatureDependencyLoader
    # Loads the dependencies from the YAML file.
    # This method reads the YAML file containing feature dependencies and returns
    # a hash of dependencies.
    # @return [Hash] A hash containing feature dependencies.
    # @raise [Togglefy::Error] If there is an error parsing the YAML file or loading dependencies.
    def self.load_dependencies!
      if defined?(@@feature_dependencies) && @@feature_dependencies.is_a?(Hash) \
          && defined?(@@inverted_feature_dependencies) && @@inverted_feature_dependencies.is_a?(Hash)
        return @@feature_dependencies, @@inverted_feature_dependencies
      end

      _dependencies = {}

      # Only load dependencies if Rails.root is defined
      # This ensures that the code runs only in a Rails application context.
      unless defined?(Rails) && Rails.respond_to?(:root) && root_path = Rails.root
        raise Togglefy::Error, "Rails.root is not set. Are you running inside a Rails application?"
      end

      file_path = File.join(root_path, "config", "togglefy.yml")

      if File.exist?(file_path)
        _dependencies = YAML.load_file(file_path) || {}

        _dependencies = _dependencies["feature_dependency"]

        _dependencies = _dependencies.keys.uniq.map do |key|
          [key, load_dependencies_for(key, _dependencies)]
        end.to_h
      end

      @@feature_dependencies = _dependencies
      @@inverted_feature_dependencies = @@feature_dependencies.values.flatten.uniq.map do |key|
        [key, load_depends_on(key, @@feature_dependencies)]
      end.to_h

      [@@feature_dependencies, @@inverted_feature_dependencies]
    rescue Psych::SyntaxError => e
      raise Togglefy::Error, "Error parsing feature dependencies file: #{e.message}"
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while loading feature dependencies: #{e.message}"
    end

    # This method returns the feature which depends on the given identifier.
    # It retrieves the dependencies from the feature_dependencies constant.
    # @param identifier [String, Symbol] The feature identifier.
    # @param dependencies [Hash] The hash containing feature dependencies.
    # @return [Array<Symbol>] An array of feature identifiers that depend on the given identifier.
    # @example
    #   load_depends_on(:feature_a, feature_dependencies)
    #   # => [:feature_b, :feature_c]
    def self.load_depends_on(identifier, dependencies)
      dependencies.select do |key, _dependencies|
        _dependencies.include?(identifier)
      end.keys
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while retrieving dependencies for '#{identifier}': #{e.message}"
    end

    # This method recursively loads dependencies for a given feature identifier.
    # @param identifier [String, Symbol] The feature identifier.
    # @param dependencies [Hash] The hash containing feature dependencies.
    # @return [Array<Symbol>] An array of dependencies for the feature identifier.
    # @example
    #   load_dependencies_for(:feature_a, feature_dependencies)
    #   # => [:feature_b, :feature_c]
    # @note This method is used internally to resolve dependencies recursively.
    # @raise [Togglefy::Error] If there is an error loading dependencies for the identifier.
    def self.load_dependencies_for(identifier, dependencies)
      direct_dependencies = dependencies[identifier] || []

      iherit_dependencies = direct_dependencies.map do |dep|
        load_dependencies_for(dep, dependencies)
      end.flatten

      direct_dependencies + iherit_dependencies
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while loading dependencies for '#{identifier}': #{e.message}"
    end

    # This method return dependencies for a given feature identifier.
    # It retrieves the dependencies from the feature_dependencies constant.
    # @param identifier [String, Symbol] The feature identifier.
    # @return [Array<Symbol>] The dependencies of the feature.
    # @raise [Togglefy::Error] If there is an error retrieving dependencies for the identifier.
    def self.dependencies_for(identifier)
      _dependencies = @@feature_dependencies[identifier] || []
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while retrieving dependencies for '#{identifier}': #{e.message}"
    end

    # This method checks if a feature has dependencies.
    # It checks if the feature identifier exists in the feature_dependencies constant.
    # @param identifier [String, Symbol] The feature identifier.
    # @return [Boolean] True if the feature has dependencies, false otherwise.
    # @raise [Togglefy::Error] If there is an error checking dependencies for the identifier.
    def self.has_dependencies?(identifier)
      @@feature_dependencies.key?(identifier)
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while checking dependencies for '#{identifier}': #{e.message}"
    end

    # This method returns all features that depend on a given feature identifier.
    # It iterates through the feature_dependencies constant and collects all features
    # that depend on the given identifier.
    # @param identifier [String, Symbol] The feature identifier.
    # @return [Array<Symbol>] An array of feature identifiers that depend on the given identifier.
    # @raise [Togglefy::Error] If there is an error retrieving features depending on the identifier.
    def self.features_depending_on(identifier)
      @@inverted_feature_dependencies[identifier.to_s] || []
    rescue StandardError => e
      raise Togglefy::Error, "An error occurred while retrieving features depending on '#{identifier}': #{e.message}"
    end
  end
end
