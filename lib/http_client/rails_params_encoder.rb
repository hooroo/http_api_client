module HttpClient
  module RailsParamsEncoder

    def self.encode(params)
      params.to_query
    end

  end
end