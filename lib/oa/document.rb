module Oa
  class Document
    attr_reader :name, :path, :root
    def initialize(name:, path:, root: {})
      @name = name
      @path = path
      @root = root
      @key_to_paths = {}
    end

    # Add paths to document
    # @param key [String] string key to manage paths. Typically, key is api controller name.
    # @param paths [Hash] openapi paths object (https://swagger.io/specification/#paths-object)
    # @example
    #   document.add_paths('UsersController', { '/users' => { get: {} } })
    #   document.add_paths('UsersController', { '/users' => { post: {} } })
    #   document.to_openapi  #=> { ..., paths: { '/users' => { get: {}, post: {} } } }
    def add_paths(key, paths)
      @key_to_paths ||= {}
      @key_to_paths[key] ||= {}
      paths.each do |path, value|
        @key_to_paths[key][path] ||= {}
        @key_to_paths[key][path].merge!(value)
      end
    end

    # Return openapi document
    # @return [Hash] openapi document
    def to_openapi
      root.merge(paths: build_openapi_paths)
    end

    # Write openapi document to file
    def generate_openapi
      require 'yaml'
      require 'fileutils'
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(YAML.dump(deep_stringify(to_openapi)))
      end
    end

    private

    def build_openapi_paths
      @key_to_paths.inject({}) do |obj, (key, paths_object)|
        paths_object.each do |path, path_object|
          obj[path] ||= {}
          path_object.each do |http_method, operation|
            obj[path][http_method] = operation
          end
        end
        obj
      end
    end

    def deep_stringify(value)
      if value.is_a?(Array)
        value.map { |v| deep_stringify(v) }
      elsif value.is_a?(Hash)
        value.map { |k, v| [k.to_s, deep_stringify(v)] }.to_h
      elsif value.is_a?(Symbol)
        value.to_s
      else
        value
      end
    end
  end
end
