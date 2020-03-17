require 'mongoid'
require 'models/location'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))
