# coding: utf-8

require 'yaml'
require 'ostruct'
require 'places_http'

module PlacesHttp
  class Config

    # attr_reader :server, :port, :base_uri

    def initialize(config_file)
      if File.exists?(config_file)

        @config = symbolize_keys(YAML.load_file(config_file)[PlacesHttp.env])


      else
        raise "Could not load config file: #{config_file}"
      end
    end

    private

    attr_reader :config

    def method_missing(method, *args, &block)
      # require 'pry'; binding.pry
      if config[method]
        OpenStruct.new(config[method])
      else
        super
      end

    end

    def symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = case key
              when String then key.to_sym
              else key
              end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end

  end
end
