#require 'rspec/core/rake_task'

#RSpec::Core::RakeTask.new do |t|
  #t.pattern = 'spec/*_spec.rb'
#end


namespace :db do
  task :require do
    require "bundler"
    Bundler.require(:default, :production)
    require "./app.rb"
  end

  desc "create the database if it doesn't exist and run DataMapper.auto_migrate! to update the schema.
  Create an admin user j@a.com password and populate with default data"
  task :init => [:require, :create, :migrate, :populate] do
    Rake.application.invoke_task("db:create_admin[j@a.com,password]")
  end

  task :create do
    `sqlite3 db/test.db ''`
    `sqlite3 db/development.db ''`
  end

  desc "create the tables to match schema"
  task :migrate => :require do
    DataMapper.auto_migrate!
  end

  desc "Update existing schema"
  task :upgrade => :require do
    DataMapper.auto_upgrade!
  end

  desc "Create an admin user. useage: rake db:create_admin[email,password]"
  task :create_admin, :email, :password do |t, args|
    require "bundler"
    Bundler.require(:default, :production)
    require './app.rb'
    params = {
      :email => args[:email],
      :password => args[:password],
      :password_confirmation => args[:password],
      :permission_level => -1
    }
    @res = User.set(params)
    unless @res.valid && @res.id && @res.permission_level == -1
      puts "error creating user: #{@res.errors}"
    end
  end

  desc "Populate database withs some seed data."
  task :populate => :require do
    TruckPricer::TruckModel.create(:name => "Century", :vin_string => "B")
    TruckPricer::TruckModel.create(:name => "Cascadia", :vin_string => "G")
    TruckPricer::Engine.create(:name => "Series 60", :vin_string => "C")
    TruckPricer::Engine.create(:name => "DD15", :vin_string => "D")
    TruckPricer::Year.create(:name => "2000", :vin_string => "0")
    TruckPricer::Year.create(:name => "2001", :vin_string => "1")
    TruckPricer::Year.create(:name => "2002", :vin_string => "2")
    TruckPricer::Year.create(:name => "2003", :vin_string => "3")
    TruckPricer::Year.create(:name => "2004", :vin_string => "4")
    TruckPricer::Year.create(:name => "2005", :vin_string => "5")
    TruckPricer::Year.create(:name => "2006", :vin_string => "6")
    TruckPricer::Year.create(:name => "2007", :vin_string => "7")
    TruckPricer::Year.create(:name => "2008", :vin_string => "8")
    TruckPricer::Year.create(:name => "2009", :vin_string => "9")
    TruckPricer::Year.create(:name => "2010", :vin_string => "A")
    TruckPricer::Year.create(:name => "2011", :vin_string => "B")
    TruckPricer::Year.create(:name => "2012", :vin_string => "C")
    TruckPricer::Year.create(:name => "2013", :vin_string => "D")
    TruckPricer::Year.create(:name => "2014", :vin_string => "E")
    TruckPricer::Year.create(:name => "2015", :vin_string => "F")
    TruckPricer::Year.create(:name => "2016", :vin_string => "G")
    TruckPricer::Year.create(:name => "2017", :vin_string => "H")
    TruckPricer::Price.raise_on_save_failure = true
    require 'bigdecimal'
    foo = TruckPricer::Price.create(:price => BigDecimal.new("40000.00"),
                                :mileage_cutoff => 200000,
                                :price_per_mile => BigDecimal.new("0.05"),
                                :price_per_mile_after_cutoff => BigDecimal.new("0.07"),
                                :price_per_mile_after_second_cutoff => BigDecimal.new("0.09"),
                                :second_mileage_cutoff => 250000,
                                :engine_id => 1,
                                :truck_model_id => 1,
                                :year_id => 1)
    puts "couldn't make it" if !foo.saved?
  end

  desc "Drop db and repopulate it"
  task :repop => [:require, :migrate, :populate]
end
