$LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include? File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "lib") unless $LOAD_PATH.include? File.join(File.dirname(__FILE__), "lib")

require 'settings'
require 'truck_pricer'
require 'bigdecimal'

use Rack::Session::Cookie, :secret => "A1 sauce 1s so good you should use 1t on a11 yr st34ksssss"
use Rack::Flash
helpers Padrino::Helpers
helpers TruckPricer::Helpers
include TruckPricer

pricer = Finder.new

get "/?" do
  if !logged_in?
    flash[:notice] = "You must be logged in to view this page."
    redirect "/login", 303
  else
    if params[:miles] and params[:vin]
      begin
        @year = pricer.year_from_vin(params[:vin].upcase.chomp)
        @engine = pricer.engine_from_vin(params[:vin].upcase.chomp)
        @model = pricer.truck_model_from_vin(params[:vin].upcase.chomp)

        @price = Price.last(:truck_model_id => @model.id, :engine_id => @engine.id, :year_id => @year.id).price_for_miles_and_base_price(params[:miles].chomp.to_i).to_s
        pp @price.class
        #if we get here it was successful, so send an email
        #Pony.mail(
        #:to => settings.email_recipient,
        #:from => settings.email_sender,
        #:subject => "User #{current_user.email} looked up a truck",
        #:body => "a body"
        #)
      rescue ModelNotFoundException => e
        flash[:error] = "Sorry, we couldn't find anything for your VIN."
        p env
        puts "#{e.message}"
        puts "#{e.backtrace}"
      rescue Exception => e
        flash[:error] = "Sorry, some other kind of error occurred: #{e.message}"
        puts "#{e.message}"
        puts "#{e.backtrace}"
      end
    end
    haml :root
  end
end

#admin form for managing the formula
get "/formula" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  else
    @formula = Formula.last
    haml :formula
  end
end

post "/formula" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  else
    formula = Formula.last
    #@TODO: validate parameters
    formula.mileage_cutoff = params[:mileage_cutoff]
    formula.price_per_mile = BigDecimal.new(params[:price_per_mile])
    formula.price_per_mile_after_cutoff = BigDecimal.new(params[:price_per_mile_after_cutoff])
    if formula.save
      flash[:success] = "Saved successfully."
    else
      flash[:failure] = "Error saving the formula. Errors: #{formula.errors}"
    end
    redirect "/formula", 303
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
      @price = Price.first(:truck_model_id => params[:truck_model_id],
                           :engine_id => params[:engine_id],
                           :year_id => params[:year_id])
      if @price
        ret = { 
          :message => "Price for the truck:",
          :price => @price.price,
          :mileage_cutoff => @price.mileage_cutoff,
          :price_per_mile => @price.price_per_mile.to_s("F"),
          :price_per_mile_after_cutoff => @price.price_per_mile_after_cutoff.to_s("F"),
          :error => false }
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
  p session
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  pp params
  @price = Price.first_or_create(:engine_id => params[:engine_id],
                                 :truck_model_id => params[:truck_model_id],
                                 :year_id => params[:year_id])
  @price.price = params[:price].chomp
  @price.mileage_cutoff = params[:mileage_cutoff].chomp
  @price.price_per_mile = BigDecimal.new(params[:price_per_mile].chomp)
  @price.price_per_mile_after_cutoff = BigDecimal.new(params[:price_per_mile_after_cutoff].chomp)
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

#Restful routes for Engine, Year and Truck Model

get "/years" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @models = Year.all
  @model_name = "year"
  @model_action = "/years"
  haml :models
end

get "/years/new" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @model_action = "/years"
  @model_name = "year"
  haml :create_model
end

post "/years" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  year = Year.new(:name => params[:name], :vin_string => params[:vin_string])
  if year.save
    flash[:success] = "Year created successfully"
    redirect "/years", 303
  else
    flash[:error] = "Error creating your year: #{year.errors}"
    redirect "/years/new", 303
  end
end

get "/years/:id/delete" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end

  if Year.get(params[:id]).destroy
    flash[:success] = "Successfully deleted year"
  else
    flash[:error] = "Error in deleting year"
  end
  redirect "/years", 303
end


get "/engines" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @models = Engine.all
  @model_name = "engine"
  @model_action = "/engines"
  haml :models
end

get "/engines/new" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @model_action = "/engines"
  @model_name = "engine"
  haml :create_model
end

post "/engines" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  engine = Engine.new(:name => params[:name], :vin_string => params[:vin_string])
  if engine.save
    flash[:success] = "Engine created successfully"
    redirect "/engines", 303
  else
    flash[:error] = "Error creating your engine: #{engine.errors}"
    redirect "/engines/new", 303
  end
end

get "/engines/:id/delete" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end

  if Engine.get(params[:id]).destroy
    flash[:success] = "Successfully deleted engine"
  else
    flash[:error] = "Error in deleting engine"
  end
  redirect "/engines", 303
end


get "/models" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @models = TruckModel.all
  @model_name = "model"
  @model_action = "/models"
  haml :models
end

get "/models/new" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  @model_action = "/models"
  @model_name = "model"
  haml :create_model
end

post "/models" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end
  model = TruckModel.new(:name => params[:name], :vin_string => params[:vin_string])
  if model.save
    flash[:success] = "TruckModel created successfully"
    redirect "/models", 303
  else
    flash[:error] = "Error creating your model: #{model.errors}"
    redirect "/models/new", 303
  end
end

get "/models/:id/delete" do
  unless current_user.admin?
    flash[:notice] = "You must be logged in to view that page."
    redirect "/", 303
  end

  if TruckModel.get(params[:id]).destroy
    flash[:success] = "Successfully deleted truck model"
  else
    flash[:error] = "Error in deleting truck model"
  end
  redirect "/models", 303
end
