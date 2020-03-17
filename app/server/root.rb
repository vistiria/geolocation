module Geolocation
  module Server
    class Root < Sinatra::Base
      include Geolocation::Models

      set :logging, true

      get '/' do
        "API: 1.0" + "\n"
      end

      get '/health_check' do
        begin
          Location.first
          return 200
        rescue => e
          logger.fatal(e)
          return 503
        end
      end
    end
  end
end
