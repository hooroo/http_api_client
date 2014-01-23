# coding: utf-8

require 'active_support/core_ext/object/to_query'
require 'faraday'
require 'oj'
require 'places_http'
require 'places_http/errors'


module PlacesHttp
  class Client

    include PlacesHttp::Errors::Factory

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

      path = full_path(base_path, query)
      log_request('GET', path)

      response = connection.get(path) do |request|
        request.headers.merge!({'Accept' => 'application/json'}).merge(headers)
      end

      handle_response(response, :get, path)
    end

    def create(base_path, payload)

      path = full_path(base_path)
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

      options = { url: "#{config.protocol}://#{config.server}" }
      options.merge!(ssl_config) if config.protocol == 'https'

      @connection ||= Faraday.new(options) do |faraday|
        faraday.port = config.port if config.port
        faraday.request   :url_encoded    # form-encode POST params
        faraday.adapter   :net_http_persistent
        # faraday.use     :http_cache
        # faraday.response  :logger
      end

    end

    private

    def config
      @config.send(client_id)
    end

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
        PlacesHttp.logger.warn("Http Client #{error_class}: #{message}")
        raise error_class, message, response.body
      end
    end


    def ssl_config
      if osx?
        osx_ssl_config
      else
        { :ssl => { :ca_path => '/etc/ssl/certs' } }
      end
    end

    def osx?
      `uname`.chomp == 'Darwin'
    end

    def osx_ssl_config

      osx_cert_file_path = '/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt'

      if File.exists?(osx_cert_file_path)
        { ssl: { :ca_file => osx_cert_file_path } }
      else
        raise "Unable to load certificate authority file at #{osx_cert_file_path}. Try `brew install curl-ca-bundle`"
      end
    end

    def ok?(response)
      Integer(response.status).between?(200, 299)
    end

    def validation_failed?(response)
      Integer(response.status) == 422
    end

    def full_path(path, query = {})

      query_with_auth = query.merge(auth_params)

      path = "/#{config.base_uri}/#{path}".gsub(/\/+/, '/')
      path = "#{path}?#{query_with_auth.to_query}" if query_with_auth && query_with_auth.keys.size > 0
      path
    end

    def log_request(method, path)
      PlacesHttp.logger.info "http_client_server_request=#{config.server}" #For splunk
      PlacesHttp.logger.info "Http Client: #{method} #{config.protocol}://#{config.server}#{path}"
    end

  end
end