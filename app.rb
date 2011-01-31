$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib") unless $LOAD_PATH.include? File.join(File.dirname(__FILE__), "lib")

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

post "/?" do
  if !logged_in?
    flash[:notice] = "You must be logged in to view this page."
    redirect "/login", 303
  else
    @price = price_for_miles(params[:miles]) * truck_price(params[:vin])
    p params
    redirect "/"
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
      flash[:success] = "Account created."
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
    p params
    if request.xhr?
      @price = TruckPricer::Price.first(:truck_model_id => params[:truck_model_id],
                                        :engine_id => params[:engine_id],
                                        :year_id => params[:year_id])
      if @price
        ret = { :message => "Here is the price for the truck!", :price => @price.price, :error => false }
        ret.to_json
      else
        ret = { :message => "No price yet for this truck, engine and year combination.", :error => true }
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
  puts "inside post /price"
  puts "*****here is the session: "
  p session
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @price = TruckPricer::Price.first_or_create(:engine_id => params[:engine_id],
                                              :truck_model_id => params[:truck_model_id],
                                              :year_id => params[:year_id])
  @price.price = params[:price]
  res = @price.save
  if request.xhr?
    if res
      ret = { :message => "Price saved successfully.", :error => false }
    else
      ret = { :message => "Errors in saving the price: #{@price.errors}", :error => true }
    end
    ret.to_json
  else
    if res
      flash[:success] = "Price saved successfully."
    else
      flash[:error] = "Error in saving the price: #{@price.errors}"
    end
    redirect "/price", 303
  end
end

def price_for_miles(miles)
  PRICE_PER_MILE = 0.05
  PRICE_PER_MILE_EXTRA = 0.07
  MILEAGE_CUTOFF = 200000
  if (miles > MILEAGE_CUTOFF)
    price = (MILEAGE_CUTOFF * PRICE_PER_MILE) + ((miles - MILEAGE_CUTOFF) * PRICE_PER_MILE_EXTRA)
  else
    price = miles * PRICE_PER_MILE
  end
  price
end

def price_for_vin(vin)
  #TODO: add some error checking!
  year_code = vin[TruckPricer::Year::VIN_INDEX]
  engine_code = vin[TruckPricer::Engine::VIN_INDEX]
  model_code = vin[TruckPricer::TruckModel::VIN_INDEX]
  year = TruckModel::Year.first(:vin_string => year_code)
  engine = TruckModel::Engine.first(:vin_string => engine_code)
  model = TruckModel::TruckModel.first(:vin_string => model_code)
  price = TruckPricer::Price.first(:year_id => year.id, :truck_model_id => model.id, :engine_id => engine.id)
end
