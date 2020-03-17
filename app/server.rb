require 'sinatra'

Dir[File.join(__dir__, 'server', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '../lib', '*.rb')].each { |file| require file }
