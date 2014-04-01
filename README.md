# HttpClient
Basic shared http related utils and error translation for places applications.

Currently:
- Http client - faraday based, configurable, threadsafe, ssl capable.
- Error translation. Translates http status codes to named errors for more precise error handling in application code.


## Usage

Create a http client by extending `HttpClient::Client` and providing a configuration key for the config relating to that client:

```ruby
module ApiClients
  class Foursquare < HttpClient::Client

    include Singleton

    def initialize
      super(:foursquare)
    end
  end
end
```

This will construct a http client configured as 'places_api' in the `config/http_clients.yml` configuration file.

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
  class Foursquare < HttpClient::Client

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

All api calls will return ruby hashed version of json responsea and translate error codes to appropriate Errors (Eg. 404 -> HttpClient::NotFound)


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

#### Tracking Request Id
In order to provide a common request id from api call to the service provider for the purposes of monitoring, a Request-Id header can be
added to all requests. In order to do this, the following config options is required:

`include_request_id_header: true`

In addition to this, your client code should have set a thread local variable keyed under `request_id`.

Eg: `Thread.current[:request_id]`

With these in place, a request header will be added to the http request which can then be picked up and logged throughout the service provider application code.

## SSL Support

SSL is supported but requires certificates for the major certificate authorities to be installed when used on OSX. Linux should have these already.

`brew install curl-ca-bundle`

This will install `/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt`

## TODO:

* Consider enforcing an SSL connection when using HTTP Basic Auth
* Where we log out ```http_client_server_request```, we should also output the time taken to respond in the same log entry.



