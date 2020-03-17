require File.expand_path('../app/boot.rb', __FILE__)

map '/' do
  run Geolocation::Server::Root
end

map '/geolocation/v1.0' do
  run Geolocation::Server::Api
end
