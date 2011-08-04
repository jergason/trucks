#Settings for application
require 'dm-core'

configure :test do
  set :db_path, "sqlite://#{File.join(File.dirname(__FILE__), 'db', 'test.db')}"
end

configure :development do |config|
  require 'sinatra/reloader'
  set :db_path, "sqlite://#{File.join(File.dirname(__FILE__), 'db', 'development.db')}"
  config.also_reload "lib/*.rb"
  config.also_reload "lib/truck_pricer/*.rb"
  config.also_reload "lib/truck_pricer/models/*.rb"

  set :email_recipient, "jergason@gmail.com"
  set :email_username, ENV["SENDGRID_USERNAME"]
  set :email_password, ENV["SENDGRID_PASSWORD"]
  set :email_domain, "localhost.localdomain"
  set :email_smtp_address, "smtp.gmail.com"
end

configure :production do |config|
  set :email_recipient, "jergason@gmail.com"
  set :email_username, ENV["SENDGRID_USERNAME"]
  set :email_password, ENV["SENDGRID_PASSWORD"]
  set :email_domain, ENV["SENDGRID_DOMAIN"]
  set :email_smtp_address, ENV["SMTP_ADDRESS"]
end

configure :production, :development, :test do
  set :email_port, "25"
  set :email_sender, "noreply@early_trade_valuation.com"
end

set :environment, :development
Pony.options = {
  :port => settings.email_port,
  :via => :smtp,
  :via_options => {
    :address => settings.email_smtp_address,
    :port => settings.email_port,
    :user_name => settings.email_username,
    :password => settings.email_password,
    :domain => settings.email_domain,
    :authentication => :plain
  }
}
#DataMapper::Logger.new($stdout, :default)
DataMapper.setup(:default, ENV['DATABASE_URL'] || settings.db_path)
