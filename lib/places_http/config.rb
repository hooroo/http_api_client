# coding: utf-8

require 'yaml'
require 'places_http'

module PlacesHttp
  class Config

    attr_reader :server, :port, :base_uri

    def initialize(config_file)
      if File.exists?(config_file)

        config = YAML.load_file(config_file)[PlacesHttp.env]

        @server = config['server']
        @port = config['port']
        @base_uri = config['base_uri']
      else
        raise "Could not load config file: #{config_file}"
      end
    end

  end
end
