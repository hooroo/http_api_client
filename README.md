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
defaults: &defaults
  places_api: &places_api_defaults
    protocol: 'http'
    base_uri: '/api/'

development:
  <<: *defaults
  places_api:
    <<: *places_api_defaults
    server: localhost
    port: 3001

test:
  <<: *defaults
  places_api:
    <<: *places_api_defaults
    server: localhost
    port: 3001

staging:
  <<: *defaults
  places_api:
    <<: *places_api_defaults
    server: staging.api.places.hooroo.com

production:
  <<: *defaults
  places_api:
    <<: *places_api_defaults
    server: api.places.hooroo.com

```

By implementing your http clients as singletons, you can make the most of faraday's persistent http connections via net_http_persistent.