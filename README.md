# PlacesHttp
Basic shared http related utils and error translation for places applications.

Currently:
- Http client - faraday based, configurable, threadsafe, ssl capable.
- Error translation. Translates http status codes to named errors for more precise error handling in application code.


## Usage

Create a http client by extending `PlacesHttp::Client` and providing a configuration key for the config relating to that client:

```ruby
class PlacesApiClient < PlacesHttp::Client

  include Singleton

  def initialize
    super(:places_api)
  end

end
```

This will construct a http client configured as 'places_api' in the `config\http_clients.yml` configuration file.

Eg:
```
test:
  my_client:
    protocol: 'http'
    server: example.com
    port: 80
    base_uri: 'api/'


```

By implementing your http clients as singletons, you can make the most of faraday's persistent http connections via net_http_persistent. This can have a significant impact on performance for chatty apps assuming that the target server implements keep-alive.

### Specifiying Authentication Params





