$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include? File.dirname(__FILE__)
require "bundler"
Bundler.setup

run Sinatra::Application
