require 'places_http'

module PlacesHttp

  module Errors

    class BaseError < StandardError

      attr_reader :response_body, :nested_error

      def initialize(message, response_body = '', nested_error = nil)
        super(message)
        @message = message
        @response_body = response_body
        @nested_error = nested_error
      end

      def message
        messages = [@message]
        messages << nested_error.message if nested_error
        messages << response_body
        messages.join("\n\n")
      end

    end

    #400 Range
    class BadRequest < BaseError ; end
    class Unauthorised < BaseError ; end
    class Forbidden < BaseError ; end
    class NotFound < BaseError ; end
    class MethodNotAllowed < BaseError ; end
    class NotAcceptable < BaseError ; end
    class RequestTimeout < BaseError ; end
    class UnknownStatus < BaseError ; end
    class UnprocessableEntity < BaseError ; end
    class TooManyRequests < BaseError ; end

    #500 Range
    class InternalServerError < BaseError ; end
    class NotImplemented < BaseError ; end
    class BadGateway < BaseError ; end
    class ServiceUnavailable < BaseError ; end
    class GatewayTimeout < BaseError ; end

    module Factory

      def error_for_status(status)
        case status
        when 400
          BadRequest
        when 401
          Unauthorized
        when 403
          Forbidden
        when 404
          NotFound
        when 405
          MethodNotAllowed
        when 406
          NotAcceptable
        when 408
          RequestTimeout

        when 422
          UnprocessableEntity

        when 429
          TooManyRequests

        when 500
          InternalServerError
        when 501
          NotImplemented
        when 502
          BadGateway
        when 503
          ServiceUnavailable
        when 504
           GatewayTimeout

        else
          UnknownStatus
        end
      end
    end

  end

end
