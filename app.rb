$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib") unless $LOAD_PATH.include? File.join(File.dirname(__FILE__), "lib")

require 'settings'
require 'truck_pricer'

use Rack::Session::Cookie, :secret => "A1 sauce 1s so good you should use 1t on a11 yr st34ksssss"
use Rack::Flash
helpers Padrino::Helpers
helpers TruckPricer::Helpers
include TruckPricer

get "/?" do
  if !logged_in?
    flash[:notice] = "You must be logged in to view this page."
    redirect "/login", 303
  else
    if params[:miles] and params[:vin]
      p params
      begin
        price_for_vin = price_for_vin(params[:vin].upcase)
        @price = Formula.last.price_for_miles_and_base_price(params[:miles].to_i, price_for_vin)
      rescue ModelNotFoundException => e
        flash[:error] = "Sorry, we couldn't find anything for your VIN."
        p env
        puts "#{e.message}"
        puts "#{e.backtrace}"
      #rescue Exception => e
        #flash[:error] = "Sorry, some other kind of error occurred: #{e.message}"
        #puts "#{e.message}"
        #puts "#{e.backtrace}"
      end
    end
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
    pp params
    if request.xhr?
      @price = Price.first(:truck_model_id => params[:truck_model_id],
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
      @truck_model_options = options_array TruckModel.all
      @engine_options = options_array Engine.all
      @year_options = options_array Year.all
      haml :price
    end
  end
end

post "/price" do
  puts "inside post /price"
  puts "*****here is the session: "
  pp session
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @price = Price.first_or_create(:engine_id => params[:engine_id],
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
  if (miles > MILEAGE_CUTOFF)
    price = (MILEAGE_CUTOFF * PRICE_PER_MILE) + ((miles - MILEAGE_CUTOFF) * PRICE_PER_MILE_EXTRA)
  else
    price = miles * PRICE_PER_MILE
  end
  price
end

def price_for_vin(vin)
  #TODO: add some error checking for the models and years
  year_code = vin[Year::VIN_INDEX]
  engine_code = vin[Engine::VIN_INDEX]
  model_code = vin[TruckModel::VIN_INDEX]
  puts "year_code is #{year_code}, engine_code is #{engine_code}, model_code is #{model_code}"
  year = Year.first(:vin_string => year_code)
  engine = Engine.first(:vin_string => engine_code)
  model = TruckModel.first(:vin_string => model_code)
  [year, engine, model].each { |m| raise ModelNotFoundException, "couldn't find model for #{m}" if m.nil?
    puts "m is: "
    pp m
  }
  price = Price.first(:year_id => year.id, :truck_model_id => model.id, :engine_id => engine.id)
  unless price
    raise ModelNotFoundException, "No price for year: #{year.name}, engine: #{engine.name}, model: #{model.name}"
  else
    price.price
  end
end
