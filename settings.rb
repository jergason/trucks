#Settings for application
require 'dm-core'

configure :test do
  set :db_path, "sqlite://#{File.join(File.dirname(__FILE__), 'db', 'test.db')}"
end

configure :development do
  set :db_path, "sqlite://#{File.join(File.dirname(__FILE__), 'db', 'development.db')}"
end

set :environment, :development
DataMapper::Logger.new($stdout, :default)
DataMapper.setup(:default, ENV['DATABASE_URL'] || settings.db_path)
