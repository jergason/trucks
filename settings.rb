#Settings for application
require 'dm-core'
require 'dm-aggregates'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:///Users/jergason/Dropbox/warner_trucks/trucks.db")
