# HttpApiClient
Basic shared http related utils and error translation for places applications.

Currently:
- Http client - faraday based, configurable, threadsafe, ssl capable.
- Error translation. Translates http status codes to named errors for more precise error handling in application code.


## Usage

Create a http client by extending `HttpApiClient::Client` and providing a configuration key for the config relating to that client:

```ruby
module ApiClients
  class Foursquare < HttpApiClient::Client

    include Singleton

    def initialize
      super(:foursquare)
    end
  end
end
```

This will construct a http client configured as 'places_api' in the `config/http_api_clients.yml` configuration file.

Eg:
```
production:
  foursquare:
    protocol: https
    server: api.foursquare.com
    #port: 443 (not required)
    #base_uri: '' (not required)

development:
  foursquare:
    protocol: https
    server: api.foursquare.com
    #port: 443 (not required)
    #base_uri: '' (not required)


#etc. Regular yaml defaults / overrides etc can be used to keep DRY

```

### Possible keys

* ```protocol```              - protocol, e.g. **https** or **http**
* ```server```                - the host name, e.g. **api.foursquare.com**
* ```port```                  - self-explanatory (not required)
* ```base_uri```              - base path/uri e.g. **/api** (not required)
* ```http_basic_username```   - username for HTTP Basic Auth (not required)
* ```http_basic_password```   - password for HTTP Basic Auth (not required)
* ```ca_file```               - the path to a self-signed cert authority file, e.g. **/usr/local/etc/nginx/my-server.crt** (not required)

By implementing your http clients as singletons, you can make the most of faraday's persistent http connections via net_http_persistent. This can have a significant impact on performance for chatty apps assuming that the target server implements keep-alive.

### Specifiying Token Authentication Params

Some http apis such as foursquare or instagram require auth params to be passed. These can be defined at the client level by implementing the `auth_params` method.

```ruby
module ApiClients
  class Foursquare < HttpApiClient::Client

    include Singleton

    def initialize
      super(:foursquare)
    end

    def auth_params
      {
        client_id: Application.config.foursquare_client_id,
        client_secret: Application.config.foursquare_secret,
        v: Date.today.strftime('%Y%m%d')
      }
    end

  end
end
```

### Current API

All api calls will return ruby hashed version of json responsea and translate error codes to appropriate Errors (Eg. 404 -> HttpApiClient::NotFound)


#### Raw Http Api
```ruby
# GET
client.get(base_path, params, headers)

# POST
client.create(base_path, payload)

# DELETE
client.destroy(base_path, id)

# UPDATE  - Not yet implemented (if you need it, add it)

```

#### Higher level Api

Not sure if this belongs here yet. It may be removed. These all just pass through to `client.get`

```ruby
# GET
client.find(base_path, id, query = {})

client.find_nested(base_path, id, nested_path)

client.find_all(base_path, query = {})

```

#### Request Id Tracking
In order to provide a common request id from api call to the service provider for the purposes of monitoring, a Request-Id header can be added to all requests. In order to do this, the following config options is required:

`include_request_id_header: true`

In addition to this, your client code should have set a thread local variable keyed under `request_id`.

Eg: `Thread.current[:request_id] = request_id`

With these in place, a request header (X-Request-Id) will be added to the http request which can then be picked up and logged throughout the service provider application code.

Another option, with a use intended for tracking across asynchronous processes is the correlation_id.

`include_correlation_id_header: true`

This will work in the same way, allowing the correlation id to be passed via the X-Correlation-Id header.

## SSL Support

SSL is supported but requires certificates for the major certificate authorities to be installed when used on OSX. Linux should have these already.

`brew install curl-ca-bundle`

This will install `/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt`

## TODO:

* Consider enforcing an SSL connection when using HTTP Basic Auth

## Release Notes

### 0.1.0 - 2014-04-03
* Initial release

### 0.1.1 - 2014-04-04
* Allow logger to be injected

### 0.1.2 - 2014-04-04
* Update logging to be less generic to avoid clash with other log fields

### 0.1.3 - 2014-04-07
* Fix issue with adding a nil request id when a client is configured to add header to requests

### 0.1.4 - 2014-04-07
* Don't url encode log values

### 0.1.5 - 2014-04-08
* Logging and metrics are separate concerns and both are injectable

### 0.2.0 - 2014-04-08
* 422's are now treated as exceptional which allows much easier use of http_api_client when not using Hooroo Api Tools. This moved some responsibility away from http_api_client into HoorooApiTools

### 0.2.1 - 2014-04-08
* A couple of code cleanup actions

### 0.2.2 - 2014-04-08
* TimedResult class is now no longer in the global namespace. It is in the HttpApiClient namespace now. Fixes problems with name collisions

### 0.2.3 - 2014-05-05
* Add logging for json parsing failures
* Remove unused timed result

### 0.2.4 - 2014-05-06
* Switch to vanilla net_http rather than net_http_persistent to see if a couple of connection / response issues resolve.

### 0.2.5 - 2014-06-13
* Allow for earlier version of faraday

### 0.2.6 - 2014-10-07
* Convert hash contents (dates etc) to correct JSON format before sending over the wire.
