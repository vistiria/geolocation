require 'cgi'
module Geolocation
  module Base
    include Geolocation::Models
    include Geolocation::Utils

    def handle_error(code, response)
        halt code, response.to_json
    end

    def location_find_by(params)
      begin
        location = Location.find_by(params)
      rescue Mongoid::Errors::DocumentNotFound => e
        handle_error(HTTP_NOT_FOUND, { error: "geolocation data does not exist" })
      end
      location
    end

    def check_if_exists(params)
      if Location.where(params).exists?
        handle_error(HTTP_UNPROCESSABLE_ENTITY, { error: "geolocation data already exists" })
      end
    end

    def check_if_valid_ip(ip)
      if !IPAddress.valid_ipv4? ip
        handle_error(HTTP_UNPROCESSABLE_ENTITY, { error: "provided ip: #{ip} is not valid IPv4 address" })
      end
    end

    def check_if_valid_url(url)
      begin
        uri = URI.parse(url)
        uri = URI.parse("http://#{url}") if uri.scheme.nil?
        host = uri.host
      rescue URI::InvalidURIError
        handle_error(HTTP_UNPROCESSABLE_ENTITY, { error: "provided url: #{url} is not valid" })
      end
      host = host[4..] if host.start_with?('www')

      begin
        ip = Resolv.getaddress(host)
      rescue => e
        handle_error(HTTP_UNPROCESSABLE_ENTITY, { error: "provided url: #{url} is not valid" })
      end
      [ip, host]
    end

    def location_data(location)
      {
        ip: location[:ip],
        host: location[:host],
        latitude: location[:latitude],
        longitude: location[:longitude]
      }.to_json
    end

    def self.included(base)
      base.module_eval do
        configure do
          set :show_exceptions, false
          set :logging, true
        end

        error Mongo::Error::NoServerAvailable do
          logger.fatal("Mongo::Error::NoServerAvailable")
          halt HTTP_SERVICE_UNAVAILABLE
        end

        error Mongoid::Errors::Validations do
          halt HTTP_UNPROCESSABLE_ENTITY
        end

        options '/*' do
          headers = {
            "Access-Control-Allow-Methods" => "GET, POST, DELETE, OPTIONS",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Headers" => "Origin, Accept",
          }
          [HTTP_OK, headers, ['']]
        end

        before do
          return if request.request_method == 'OPTIONS'
          content_type 'application/json'
          headers.merge!(
            'Access-Control-Allow-Methods' => 'GET, POST, DELETE, OPTIONS',
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Headers' => "Origin, Accept",
          )

          if request.url.include? "/url/"
            url_param = request.url[/.*\/url\/(.*)/, 1]
            url_param.sub!("/","%2F%2F")
            params[:url] = CGI.unescape(url_param)
            env['PATH_INFO'] = "/url"
          end
        end
      end
    end
  end
end
