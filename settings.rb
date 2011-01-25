#Settings for application
require 'dm-core'

configure :test do
  set :db_path, 'sqlite:///Users/jergason/Dropbox/warner_trucks/db/test.db'
end

configure :development do
  set :db_path, 'sqlite:///Users/jergason/Dropbox/warner_trucks/db/development.db'
end

DataMapper::Logger.new($stdout, :default)
DataMapper.setup(:default, ENV['DATABASE_URL'] || settings.db_path)
