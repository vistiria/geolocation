require_relative 'base'

module Geolocation
  module Server
    class Api < Sinatra::Base
      include Geolocation::Base
      include Geolocation::Models
      include Geolocation::Utils

      post '/ip/:ip' do
        check_if_valid_ip(params[:ip])
        check_if_exists({ ip: params[:ip] })

        success, code, ipstack_resp = Geolocation::IpstackService.new(ip: params[:ip]).call
        if !success
          handle_error(code, ipstack_resp)
        end

        location = Location.create!(ipstack_resp)

        status HTTP_CREATED
        return location_data(location)
      end

      post '/url' do
        ip, host = check_if_valid_url(params[:url])
        check_if_exists(host: host)

        begin
          location = Location.find_by(ip: ip)
          location.update_attribute(:host, host)
        rescue Mongoid::Errors::DocumentNotFound => e
          success, code, ipstack_resp = Geolocation::IpstackService.new(ip: ip).call
          if !success
            handle_error(code, ipstack_resp)
          end
          ipstack_resp[:host] = host
          location = Location.create!(ipstack_resp)
        end

        status HTTP_CREATED
        return location_data(location)
      end

      get '/ip/:ip' do
        check_if_valid_ip(params[:ip])
        location = location_find_by({ ip: params[:ip] })

        status HTTP_OK
        return location_data(location)
      end

      get '/url' do
        ip, host = check_if_valid_url(params[:url])

        if Location.where(host: host).exists?
          location = location_find_by({ host: host })
        else
          location = location_find_by({ip: ip})
          location.update_attribute(:host, host)
        end

        status HTTP_OK
        return location_data(location)
      end

      delete '/ip/:ip' do
        check_if_valid_ip(params[:ip])
        location = location_find_by({ ip: params[:ip] })
        location.delete

        status HTTP_NO_CONTENT
        return
      end

      delete '/url' do
        ip, host = check_if_valid_url(params[:url])

        if Location.where(host: host).exists?
          location = location_find_by({ host: host })
        else
          location = location_find_by({ ip: ip })
        end
        location.delete

        status HTTP_NO_CONTENT
        return
      end
    end
  end
end
