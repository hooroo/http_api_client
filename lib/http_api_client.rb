require "http_api_client/version"
require "http_api_client/errors"
require "http_api_client/config"
require "http_api_client/client"

module HttpApiClient


  def self.env
    if @env
      @env
    elsif rails
      rails.env
    else
      "test"
    end
  end

  def self.env=(env)
    @env = env
  end

  def self.logger
    if @logger
      @logger
    elsif rails
      rails.logger
    else
      puts 'Logger not defined, using stub logger that does nothing. Set logger via HttpApiClient.logger = my_logger'
      StubLogger
    end
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.metrics
    if @metrics
      @metrics
    else
      StubMetrics
    end
  end

  def self.metrics=(metrics)
    @metrics = metrics
  end

  def self.params_encoder
    if rails
      RailsParamsEncoder
    else
      Faraday::Utils.default_params_encoder
    end
  end

  private

  def self.rails
    Module.const_get('Rails')
  rescue NameError
    nil
  end

  class StubLogger

    def self.info(message)
      #Stub implementation
    end

    def self.debug(message)
      #Stub implementation
    end

    def self.warn(message)
      #Stub implementation
    end

    def self.error(message)
      #Stub implementation
    end

  end

  class StubMetrics

    def self.time(event_name, data, &block)
      yield
    end
  end

end
