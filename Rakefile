require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
end


namespace :db do

  task :require do
    require "./app.rb"
  end

  desc "create the if it doesn't exist and run DataMapper.auto_migrate! to update the schema.
  Create an admin user j@a.com password"
  task :init => [:require, :create, :migrate] do
    Rake.application.invoke_task("db:create_admin[j@a.com,password]")
  end

  task :create do
    `sqlite3 db/test.db ''`
    `sqlite3 db/development.db ''`
  end

  desc "create the tables to match schema, wiping out existing tables"
  task :migrate => :require do
    DataMapper.auto_migrate!
  end

  desc "Update existing schema"
  task :upgrade => :require do
    DataMapper.auto_upgrade!
  end

  desc "Create an admin user. useage: rake db:create_admin [email, password]"
  task :create_admin, :email, :password do |t, args|
    require './app.rb'
    puts "Args are #{args}"
    params = { 
      :email => args[:email],
      :password => args[:password],
      :password_confirmation => args[:password],
      :permission_level => -1
    }
    @res = User.set(params)
    unless @res.valid && @res.id && @res.permission_level == -1
      puts "error creating user!"
    end
  end
end
