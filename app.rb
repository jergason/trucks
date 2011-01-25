$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib") unless $LOAD_PATH.include? File.join(File.dirname(__FILE__), "lib")
require 'bundler'
Bundler.setup
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'digest/sha1'
require 'rack-flash'
require 'sinatra-authentication'

set :environment, :test
require 'settings'
require 'truck_pricer'

use Rack::Session::Cookie, :secret => "A1 sauce 1s so good you should use 1t on a11 yr st34ksssss"
use Rack::Flash


before do
  #pp session
  #pp env
end

get "/?" do
  if !logged_in?
    redirect "/login"
  else
    haml :root
  end
end

get "/ajax" do
  pp request
  pp env
  redirect "/" unless request.xhr?
  #@TODO: look up price

end

#show an admin form which allows creation of users
get "/create_user" do
  redirect "/" unless current_user.admin?
  haml :create_user
end

post "/create_user" do
  redirect '/' unless current_user.admin?
  if params[:permission_level]
    params[:user][:permission_level] = -1
  end
  @user = User.set(params[:user])
  if @user.valid && @user.id
    #session[:user] = @user.id
    flash[:notice] = "Account created."
    redirect '/create_user'
  else
    flash[:error] = "There were some problems creating the account: #{@user.errors}."
    redirect '/create_user?' + hash_to_query_string(params)
  end
end

#set the price for a combination
post "/price_combination" do
  redirect "/" unless request.xhr? or current_user.admin?
  @fomrula = TruckPricer::PriceFormula.first_or_create(:engine_id => params[:engine_id],
                                            :truck_model_id => params[:truck_model_id],
                                            :year_id => params[:year_id])
  @formula.price
end
