$LOAD_PATH << '../lib/'

require 'faraday'
require 'yaml'
require 'erb'
require 'ipaddress'

ROOT_DIR = ENV['ROOT_DIR'] || '.'

Config = if ENV['RACK_ENV'] == 'test'
           YAML.safe_load(ERB.new(File.read("#{ROOT_DIR}/config/test.yml")).result)
         else
           YAML.safe_load(ERB.new(File.read("#{ROOT_DIR}/config/default.yml")).result)
         end
