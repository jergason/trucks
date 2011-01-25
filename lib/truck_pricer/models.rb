$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
require 'dm-core'
require 'dm-migrations'
require 'models/engine'
require 'models/truck_model'
require 'models/year'
require 'models/price'

DataMapper.finalize
