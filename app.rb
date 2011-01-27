$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib") unless $LOAD_PATH.include? File.join(File.dirname(__FILE__), "lib")
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

use Rack::Session::Cookie, :secret => "What good is a secret key if it doesn't have some gibberish@@#AKGHFKAA?"
use Rack::Flash
helpers Padrino::Helpers
helpers TruckPricer::Helpers

get "/?" do
  if !logged_in?
    flash[:notice] = "You must be logged in to view this page."
    redirect "/login", 303
  else
    haml :root
  end
end

#show an admin form which allows creation of users
get "/create_user" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  else
    haml :create_user
  end
end

post "/create_user" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  else
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
end

get "/price" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  else
    puts "HERE ARE THE PARAMS: "
    pp params
    if request.xhr?
      @price = TruckPricer::Price.first(:truck_model_id => params[:truck_model_id],
                                        :engine_id => params[:engine_id],
                                        :year => params[:year_id])
      puts "**In get /price and @price is: "
      pp @price
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
end

post "/price" do
  #@TODO: only xhr requests?
  puts "inside post /price"
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  puts "********* Here are the params: "
  @price = TruckPricer::Price.first_or_create(:engine_id => params[:engine_id],
                                            :truck_model_id => params[:truck_model_id],
                                            :year_id => params[:year_id])
  @price.price = params[:price]
  if @price.save
    ret = { :message => "Price saved successfully.", :error => false }
  else
    ret = { :message => "Errors in saving the price: #{@price.errors}", :error => true }
  end
    #haml :price
  ret.to_json
end
