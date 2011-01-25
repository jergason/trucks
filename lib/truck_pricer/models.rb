$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
require 'models/model'
require 'models/engine'
require 'models/truck_model'

DataMapper.finalize
