# PlacesHttp
Basic shared http related utils and error translation for places applications.

Currently:
- Http client - faraday based, configurable, threadsafe, ssl capable.
- Error translation. Translates http status codes to named errors for more precise error handling in application code.


## Usage

Create a http client by extending `PlacesHttp::Client` and providing a configuration key for the config relating to that client:

```ruby
module ApiClients
  class Foursquare < PlacesHttp::Client

    include Singleton

    def initialize
      super(:foursquare)
    end
  end
end
```

This will construct a http client configured as 'places_api' in the `config\http_clients.yml` configuration file.

Eg:
```
production:
  foursquare:
    protocol: 'https'
    server: api.foursquare.com
    #port: 443 (not required)
    #base_uri: '' (not required)

development:
  foursquare:
    protocol: 'https'
    server: api.foursquare.com
    #port: 443 (not required)
    #base_uri: '' (not required)


#etc. Regular yaml defaults / overrides etc can be used to keep DRY

```

By implementing your http clients as singletons, you can make the most of faraday's persistent http connections via net_http_persistent. This can have a significant impact on performance for chatty apps assuming that the target server implements keep-alive.

### Specifiying Authentication Params

Some http apis such as foursquare or instagram require auth params to be passed. These can be defined at the client level by implementing the `auth_params` method.

```ruby
module ApiClients
  class Foursquare < PlacesHttp::Client

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

All api calls will return ruby hashed version of json responsea and translate error codes to appropriate Errors (Eg. 404 -> PlacesHttp::NotFound)


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




