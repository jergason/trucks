$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include? File.dirname(__FILE__)
require "bundler"
Bundler.require(:default, :development, :test)

require 'app'
run Sinatra::Application
