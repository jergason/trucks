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
require 'padrino-helpers'

require 'settings'
require 'truck_pricer'

use Rack::Session::Cookie, :secret => "A1 sauce 1s so good you should use 1t on a11 yr st34ksssss"
use Rack::Flash
helpers Padrino::Helpers
helpers TruckPricer::Helpers

get "/?" do
  if !logged_in?
    redirect "/login", 303
  else
    haml :root
  end
end

#show an admin form which allows creation of users
get "/create_user" do
  redirect "/", 303 unless current_user.admin?
  haml :create_user
end

post "/create_user" do
  redirect '/', 303 unless current_user.admin?
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
    redirect '/create_user?' + hash_to_query_string(params), 303
  end
end

get "/price" do
  #redirect "/", 303 unless current_user.admin?
  if request.xhr?
    @price = TruckPricer::Price.first(:truck_model_id => params[:truck_model],
                                      :engine_id => params[:engine],
                                      :year => params[:year])
    if @price
      ret = { :message => "Here is the price for the truck!", :price => @price.price, :error => false }
      ret.to_json
    else
      ret = { :message => "no truck found", :error => true }
      ret.to_json
    end
  else
    @truck_model_options = options_array TruckPricer::TruckModel.all
    @engine_options = options_array TruckPricer::Engine.all
    @year_options = options_array TruckPricer::Year.all
    haml :price
  end
end

post "/price" do
  #@TODO: only xhr requests?
  redirect "/" unless current_user.admin?
  @price = TruckPricer::Price.first_or_create(:engine_id => params[:engine_id],
                                            :truck_model_id => params[:truck_model_id],
                                            :year_id => params[:year_id])
  @price.price = params[:price]
  if @price.save
    flash[:success] = "Price saved."
  else
    flash[:error] = "Error in saving price"
  end
  if request.xhr?
    return "HURP DE DURP"
  else
    redirect "/price"
  end
end
