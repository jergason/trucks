require File.join(File.dirname(__FILE__), "..", "app.rb")

require 'rack/test'
require 'rspec'

set :environment, :test
set :run, false
set :raise_error, :true
set :logging, :false

DataMapper::Logger.new($stdout, :debug)
puts "settings.db_path is #{settings.db_path}"
DataMapper.setup(:default, settings.db_path)
