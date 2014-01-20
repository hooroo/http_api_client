# coding: utf-8

require 'active_support/core_ext/object/to_query'
require 'faraday'
require 'oj'
require 'places_http'
require 'places_http/errors'


module PlacesHttp
  class Client

    include PlacesHttp::Errors::Factory

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def find(base_path, id, query = {})
      get("#{base_path}/#{id}", query)
    end

    def find_nested(base_path, id, nested_path)
      get("#{base_path}/#{id}/#{nested_path}")
    end

    def find_all(base_path, query = {})
      get("#{base_path}", query)
    end

    def get(base_path, query = nil)

      path = full_path(base_path, query)
      log_request('GET', path)

      response = connection.get(path) do |request|
        request.headers['Accept'] = 'application/json'
      end

      handle_response(response, :get, path)
    end

    def create(base_path, payload)

      path = full_path(base_path)
      log_request('POST', path)

      response = connection.post(path, payload.to_query) do |request|
        request.headers['Accept'] = 'application/json'
      end
      handle_response(response, :post, path)
    end

    def destroy(base_path, id)

      path = "#{base_path}/#{id}"
      log_request('DELETE', path)

      response = connection.delete(full_path(path))
      handle_response(response, :delete, path)
    end

    private

    def handle_response(response, method, path)
      if ok?(response) || validation_failed?(response)
        if response.body
          Oj.strict_load(response.body) #Don't use regular load method - any strings starting with ':' will be interpreted as a symbol
        else
          true
        end
      else
        error_class = error_for_status(response.status)
        summary = "#{response.status} #{method}: #{path}"
        PlacesHttp.logger.warn("ApiClient #{error_class}: #{summary}")
        raise error_class, summary
      end
    end

    def connection
      @connection ||= Faraday.new(:url => "http://#{config.server}") do |faraday|
        faraday.port = config.port
        faraday.request   :url_encoded    # form-encode POST params
        faraday.adapter   Faraday.default_adapter
        # faraday.use     :http_cache
        # faraday.response  :logger
      end
    end

    def ok?(response)
      Integer(response.status).between?(200, 299)
    end

    def validation_failed?(response)
      Integer(response.status) == 422
    end

    def full_path(path, query = nil)
      path = "/#{config.base_uri}/#{path}".gsub(/\/+/, '/')
      path = "#{path}?#{query.to_query}" if query && query.keys.size > 0
      path
    end

    def log_request(method, path)
      PlacesHttp.logger.info "api_client_base_uri=#{config.server}" #For splunk
      PlacesHttp.logger.info "Http Client (#{method}): #{path}"
    end

  end
end