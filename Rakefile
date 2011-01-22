require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
end


namespace :db do

  task :require do
    require "sinatra"
    require "./app.rb"
    require "./settings.rb"
    require "dm-migrations"
  end

  desc "create the database and point the db driver at it"
  task :init => [:require, :create, :migrate]

  task :create do
    `sqlite3 trucks.db ''`
  end

  desc "create the tables to match schema, wiping out existing tables"
  task :migrate => :require do
    DataMapper.auto_migrate!
  end

  desc "Update existing schema"
  task :upgrade => :require do
    DataMapper.auto_upgrade!
  end
end
