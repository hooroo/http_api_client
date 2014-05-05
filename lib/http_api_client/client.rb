# coding: utf-8

require 'active_support/core_ext/object/to_query'
require "active_support/json"
require 'faraday'
require 'oj'
require 'http_api_client'
require 'http_api_client/errors'
require 'http_api_client/connection_factory'
require 'http_api_client/timed_result'

module HttpApiClient
  class Client

    include HttpApiClient::Errors::Factory

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

    def get(path, query = {}, custom_headers = {})

      log_data = { method: 'get', remote_host: config.server, path: path_with_query(path, query) }

      response = HttpApiClient.metrics.time('http_api_client_request', log_data) do
        connection.get(full_path(path), with_auth(query), request_headers(get_headers, custom_headers))
      end

      handle_response(response, :get, path)
    end

    def create(path, payload, custom_headers = {})

      log_data = { method: 'post', remote_host: config.server, path: full_path(path) }

      response = HttpApiClient.metrics.time('http_api_client_request', log_data) do
        connection.post(full_path(path), JSON.fast_generate(with_auth(payload)), request_headers(update_headers, custom_headers))
      end

      handle_response(response, :post, path)
    end

    def destroy(base_path, id, custom_headers = {})

      path = "#{base_path}/#{id}"
      log_data = { method: 'delete', remote_host: config.server, path: full_path(path) }

      response = HttpApiClient.metrics.time('http_api_client_request', log_data) do
        connection.delete(full_path(path), request_headers(update_headers, custom_headers))
      end

      handle_response(response, :delete, path)
    end

    def connection
      @connection ||= ConnectionFactory.new(config).create
    end

    private

    def params_encoder
      @params_encoder ||= HttpApiClient.params_encoder
    end

    def auth_params
      {}
    end

    def handle_response(response, method, path)
      if ok?(response)
        if response.body
          begin
            #Don't use regular load method - any strings starting with ':' ( :-)  from example) will be interpreted as a symbol
            Oj.strict_load(response.body)

          rescue Oj::ParseError => e

            HttpApiClient.logger.error(
              error_class: 'OJ::ParseError',
              message: e.message,
              backtrace: e.backtrace,
              json: response.body
              )

            raise e
          end
        else
          true
        end
      else
        error_class = error_for_status(response.status)
        message = "#{response.status} #{method}: #{path}"
        HttpApiClient.logger.info("Http Client #{error_class}: #{message}")
        raise error_class.new(message, response.body)
      end
    end

    def ok?(response)
      Integer(response.status).between?(200, 299)
    end

    def full_path(path)
      path = "/#{config.base_uri}/#{path}".gsub(/\/+/, '/')
      path
    end

    def path_with_query(path, query)
      path = full_path(path)
      path += "?#{params_encoder.encode(query)}" unless query.keys.empty?
      path
    end

    def with_auth(query)
      query.merge(auth_params)
    end

    def request_headers(base_headers, custom_headers = {})
      all_headers = base_headers.merge(custom_headers)
      all_headers.merge!({'X-Request-Id' => Thread.current[:request_id]}) if include_request_id_header?
      all_headers
    end

    def include_request_id_header?
      config.include_request_id_header && Thread.current[:request_id] != nil
    end

    def get_headers
      {
        'Accept' => 'application/json'
      }
    end

    def update_headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

  end
end