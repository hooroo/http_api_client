require 'http_api_client/rails_params_encoder'

module HttpApiClient
  class ConnectionFactory

    OSX_CERT_PATH = '/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt'

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def create

      Faraday.new(connection_options) do |connection|
        connection.port = config.port if config.port
        connection.request   :url_encoded    # form-encode POST params
        connection.adapter   :net_http
        # connection.use     :http_cache
        # connection.response  :logger

        if config.http_basic_username
          connection.basic_auth(config.http_basic_username, config.http_basic_password)
        end
      end

    end

    private

    def connection_options
      options = { url: "#{config.protocol}://#{config.server}" }
      options.merge!(ssl_config) if config.protocol == 'https'
      options.merge!({ request: { params_encoder: HttpApiClient.params_encoder } }) if {}.respond_to?(:to_query)
      options
    end

    def ssl_config
      return { ssl: { ca_file: config.ca_file } }  if config.ca_file
      return { ssl: { ca_file: osx_ssl_ca_file } } if osx?
      return { ssl: { ca_path: '/etc/ssl/certs' } }
    end

    def osx?
      `uname`.chomp == 'Darwin'
    end

    def osx_ssl_ca_file
      if File.exists?(OSX_CERT_PATH)
         OSX_CERT_PATH
      else
        raise "Unable to load certificate authority file at #{OSX_CERT_PATH}. Try `brew install curl-ca-bundle`"
      end
    end

  end
end