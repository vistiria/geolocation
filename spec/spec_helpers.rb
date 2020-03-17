$LOAD_PATH << './lib'
$LOAD_PATH << './app'

ENV['RACK_ENV'] = 'test'

require 'utils'
require 'config'
require 'models'
require 'server'
require 'sinatra'
require 'rack/test'



module RSpecMixin
  include Rack::Test::Methods
  def app() Geolocation::Server::Api end
end
RSpec.configure { |c| c.include RSpecMixin }
