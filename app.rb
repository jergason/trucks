require 'sinatra'
require 'dm-core'
require 'sinatra-authentication'
require 'rack-flash'

enable :sessions
use Rack::Flash

get "/?" do
  "HELLO WORLD!"
end

