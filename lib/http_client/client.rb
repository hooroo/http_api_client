# coding: utf-8

require 'active_support/core_ext/object/to_query'
require 'faraday'
require 'oj'
require 'http_client'
require 'http_client/errors'
require 'http_client/connection_factory'

module HttpClient
  class Client

    include HttpClient::Errors::Factory

    attr_reader :config

    def initialize(client_id, config_file = nil)
      raise "You must supply a http client config id (as defined in #{config_file || Config::DEFAULT_CONFIG_FILE_LOCATION}" unless client_id

      if config_file
        @config = Config.new(config_file).send(client_id)
      else
        @config = Config.new.send(client_id)
      end
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

    def get(path, query = {}, headers = {})

      log_request('GET', path)

      response = connection.get(full_path(path), full_query(query), request_headers(headers))

      handle_response(response, :get, path)
    end

    def create(path, payload, headers = {})

      log_request('POST', path)

      response = connection.post(full_path(path), full_query(payload).to_query, request_headers(headers))

      handle_response(response, :post, path)
    end

    def destroy(base_path, id, headers = {})
      path = "#{base_path}/#{id}"
      log_request('DELETE', path)

      response = connection.delete(full_path(path), request_headers(headers))

      handle_response(response, :delete, path)
    end

    def connection
      @connection ||= ConnectionFactory.new(config).create
    end

    private

    def auth_params
      {}
    end

    def handle_response(response, method, path)
      if ok?(response) || validation_failed?(response)
        if response.body
          #Don't use regular load method - any strings starting with ':' ( :-)  from example) will be interpreted as a symbol
          Oj.strict_load(response.body)
        else
          true
        end
      else
        error_class = error_for_status(response.status)
        message = "#{response.status} #{method}: #{path}"
        HttpClient.logger.warn("Http Client #{error_class}: #{message}")
        raise error_class.new(message, response.body)
      end
    end

    def ok?(response)
      Integer(response.status).between?(200, 299)
    end

    def validation_failed?(response)
      Integer(response.status) == 422
    end

    def full_path(path)
      path = "/#{config.base_uri}/#{path}".gsub(/\/+/, '/')
      path
    end

    def full_path_with_query(path, query)
      path = "/#{config.base_uri}/#{path}".gsub(/\/+/, '/')
      path += "?#{query.to_query}" unless query.keys.empty?
      path
    end

    def full_query(query)
      query.merge(auth_params)
    end

    def request_headers(headers)
      all_headers = default_accept_header.merge(headers)
      all_headers.merge!({'Request-Id' => Thread.current[:request_id]}) if config.include_request_id_header
      all_headers
    end

    def default_accept_header
      {'Accept' => 'application/json'}
    end

    def log_request(method, path)
      HttpClient.logger.info "http_client_server_request=#{config.server}" #For splunk
      HttpClient.logger.info "Http Client: #{method} #{config.protocol}://#{config.server}#{path}"
    end

  end
end