module Geolocation
  class IpstackService
    include Geolocation::Utils

    IPSTACK_ENDPOINT = '/api.ipstack.com'.freeze

    def initialize(ip:)
      @ip = ip
    end

    def call
      response = http.get build_url
      begin
        body = JSON.parse(response.body)
      rescue JSON::ParserError
        body = {}
      end
      process_response(body.with_indifferent_access, response.success?, response.status)
    end

    def process_response(json_body, response_success, status)
      if response_success
        if json_body["success"] == false
          case json_body["error"]["code"].to_i
          when HTTP_NOT_FOUND
            [false, HTTP_NOT_FOUND, { error: json_body["error"]["info"] }]
          else
            p "ERROR: ipstack response - #{json_body}"
            [false, HTTP_SERVICE_UNAVAILABLE, { error: 'Service Unavailable' }]
          end
        else
          if !json_body["latitude"] || !json_body["latitude"]
            p "ERROR: ipstack response - #{json_body}"
            [false, HTTP_NOT_FOUND, { error: "The requested resource does not exist." }]
          else
            [true, HTTP_OK, json_body]
          end
        end
      else
        p "ERROR: ipstack not responding - code: #{status}"
        [false, HTTP_SERVICE_UNAVAILABLE, { error: 'Service Unavailable' }]
      end
    end

    private

    def build_url
      resource = "/#{IPSTACK_ENDPOINT}/#{@ip}?"
      resource + to_query_parameters("access_key" => api_access_key,
                                     "fields" => "ip,latitude,longitude",
                                     "language" => "en", "output" => "json")
    end

    def to_query_parameters(params)
      params.map { |key, value| key + '=' + value }.join('&')
    end

    def api_access_key
      @api_access_key ||= Config["api_access_key"]
    end

    def ipstack_url
      @url ||= Config["ipstack_url"]
    end

    def http
      @http ||= Faraday.new(ipstack_url)
    end
  end
end
