# coding: utf-8

require 'active_support/core_ext/object/to_query'
require 'faraday'
require 'oj'
require 'http_client'
require 'http_client/errors'


module HttpClient
  class Client

    OSX_CERT_PATH = '/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt'

    include HttpClient::Errors::Factory

    attr_reader :client_id

    def initialize(client_id, config_file = nil)
      raise "You must supply a http client config id (as defined in #{config_file || Config::DEFAULT_CONFIG_FILE_LOCATION}" unless client_id
      @client_id = client_id

      if config_file
        @config = Config.new(config_file)
      else
        @config = Config.new
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

    def get(base_path, query = {}, headers = {})
      path = full_path(base_path)
      query = full_query(query)
      log_request('GET', path)

      response = connection.get(path, query) do |request|
        request.headers.merge!({'Accept' => 'application/json'}).merge(headers)
      end

      handle_response(response, :get, path)
    end

    def create(base_path, payload)
      path = full_path(base_path)
      payload = full_query(payload)
      log_request('POST', path)

      response = connection.post(path, payload.to_query) do |request|
        request.headers.merge!({'Accept' => 'application/json'})
      end
      handle_response(response, :post, path)
    end

    def destroy(base_path, id)
      path = "#{base_path}/#{id}"
      log_request('DELETE', path)

      response = connection.delete(full_path(path))
      handle_response(response, :delete, path)
    end

    def connection
      @connection ||= Faraday.new(connection_options) do |faraday|
        faraday.port = config.port if config.port
        faraday.request   :url_encoded    # form-encode POST params
        faraday.adapter   :net_http_persistent
        # faraday.use     :http_cache
        # faraday.response  :logger

        if config.http_basic_username
          faraday.basic_auth config.http_basic_username, config.http_basic_password
        end
      end
    end

    private

    def config
      @config.send(client_id)
    end

    def auth_params
      {}
    end

    def connection_options
      options = { url: "#{config.protocol}://#{config.server}" }
      options.merge!(ssl_config) if config.protocol == 'https'
      options
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

    def ssl_config
      return { ssl: { ca_file: config.ca_file } }  if config.ca_file
      return { ssl: { ca_file: osx_ssl_ca_file } } if osx?
      return { ssl: { ca_path: '/etc/ssl/certs' } }
    end

    def osx_ssl_ca_file
      if File.exists?(OSX_CERT_PATH)
         OSX_CERT_PATH
      else
        raise "Unable to load certificate authority file at #{OSX_CERT_PATH}. Try `brew install curl-ca-bundle`"
      end
    end

    def osx?
      `uname`.chomp == 'Darwin'
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

    def full_query(query)
      query.merge(auth_params)
    end

    def log_request(method, path)
      HttpClient.logger.info "http_client_server_request=#{config.server}" #For splunk
      HttpClient.logger.info "Http Client: #{method} #{config.protocol}://#{config.server}#{path}"
    end

  end
end