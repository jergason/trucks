#Settings for application
require 'dm-core'
set :environment, :production
DataMapper::Logger.new($stdout, :default)
DataMapper.setup(:default, ENV['DATABASE_URL'] || settings.db_path)
