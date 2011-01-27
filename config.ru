$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include? File.dirname(__FILE__)
require "bundler"
Bundler.require(:default, :production)

require 'app'
run Sinatra::Application
