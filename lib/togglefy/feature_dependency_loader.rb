module Togglefy
  class FeatureDependencyLoader
    class << self

      # Loads the dependencies from the YAML file.
      # This method reads the YAML file containing feature dependencies and returns
      # a hash of dependencies.
      # @return [Hash] A hash containing feature dependencies.
      # @raise [Togglefy::Error] If there is an error parsing the YAML file or loading dependencies.
      def load_dependencies!
        if defined?(@@feature_dependencies) && @@feature_dependencies.is_a?(Hash) \
            && defined?(@@inverted_feature_dependencies) && @@inverted_feature_dependencies.is_a?(Hash)
          return @@feature_dependencies, @@inverted_feature_dependencies
        end

        _dependencies = {}
        
        file_path = File.join(Rails.root, 'config',  'feature_dependencies.yml')
        if File.exist?(file_path)
          _dependencies = YAML.load_file(file_path) || {}

          _dependencies.map do |key, value|
            [key.to_sym, load_dependencies_for(key, _dependencies)]
          end.to_h
        end

        @@feature_dependencies = _dependencies
        @@inverted_feature_dependencies = _dependencies.map do |key, value|
          [key.to_sym, load_dependencies_for(key, _dependencies)]
        end.to_h

        return @@feature_dependencies, @@inverted_feature_dependencies
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
      def load_depends_on(identifier, dependencies)
        dependencies.select do |key, _dependencies|
          _dependencies.include?(identifier.to_sym)
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
      def load_dependencies_for(identifier, dependencies)
        _dependencies = dependencies[identifier.to_sym] || []
        
        _dependencies += _dependencies.flat_map do |dep|
          load_dependencies_for(dep, dependencies)
        end
      rescue StandardError => e
        raise Togglefy::Error, "An error occurred while loading dependencies for '#{identifier}': #{e.message}"
      end


      # This method return dependencies for a given feature identifier.
      # It retrieves the dependencies from the feature_dependencies constant.
      # @param identifier [String, Symbol] The feature identifier.
      # @return [Array<Symbol>] The dependencies of the feature.
      # @raise [Togglefy::Error] If there is an error retrieving dependencies for the identifier.
      def dependencies_for(identifier)
        _dependencies = @@feature_dependencies[identifier.to_sym] || []
      rescue StandardError => e
        raise Togglefy::Error, "An error occurred while retrieving dependencies for '#{identifier}': #{e.message}"
      end

      # This method checks if a feature has dependencies.
      # It checks if the feature identifier exists in the feature_dependencies constant.
      # @param identifier [String, Symbol] The feature identifier.
      # @return [Boolean] True if the feature has dependencies, false otherwise.
      # @raise [Togglefy::Error] If there is an error checking dependencies for the identifier.
      def has_dependencies?(identifier)
        @@feature_dependencies.key?(identifier.to_sym)
      rescue StandardError => e
        raise Togglefy::Error, "An error occurred while checking dependencies for '#{identifier}': #{e.message}"
      end

      # This method returns all features that depend on a given feature identifier.
      # It iterates through the feature_dependencies constant and collects all features
      # that depend on the given identifier.
      # @param identifier [String, Symbol] The feature identifier.
      # @return [Array<Symbol>] An array of feature identifiers that depend on the given identifier.
      # @raise [Togglefy::Error] If there is an error retrieving features depending on the identifier.
      def features_depending_on(identifier)
        @@inverted_feature_dependencies[identifier.to_sym] || []
      rescue StandardError => e
        raise Togglefy::Error, "An error occurred while retrieving features depending on '#{identifier}': #{e.message}"
      end
    end
  end
end