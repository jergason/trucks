module TruckPricer
  class Finder
    def initialize
    end

    def price_for_vin(vin)
      #TODO: add some error checking for the models and years
      year_code = vin[Year::VIN_INDEX]
      engine_code = vin[Engine::VIN_INDEX]
      model_code = vin[TruckModel::VIN_INDEX]
      puts "vin indicies are year: #{Year::VIN_INDEX}, engine: #{Engine::VIN_INDEX}, model: #{TruckModel::VIN_INDEX}"
      puts "year_code is #{year_code}, engine_code is #{engine_code}, model_code is #{model_code}"
      year = year_from_vin(vin)#Year.first(:vin_string => year_code)
      engine = engine_from_vin(vin)#Engine.first(:vin_string => engine_code)
      model = truck_model_from_vin(vin)#TruckModel.first(:vin_string => model_code)
      [year, engine, model].each { |m| raise ModelNotFoundException, "couldn't find model for #{m}" if m.nil?
        puts "m is: "
        p m
      }
      price = Price.first(:year_id => year.id, :truck_model_id => model.id, :engine_id => engine.id)
      unless price
        raise ModelNotFoundException, "No price for year: #{year.name}, engine: #{engine.name}, model: #{model.name}"
      else
        price.price
      end
    end


    #OOOH magical
    alias method_missing_without_vin method_missing
    def method_missing(sym, *args, &blk)
      if sym.to_s =~ /^(\w+_?\w*)_from_vin$/ && args[0]
        model_from_vin($1, args[0])
      else
        method_missing_without_vin(sym, *args, &blk)
      end
    end

    alias respond_to_without_vin? respond_to?
    def respond_to?(name)
      if name.to_s =~ /^(\w+_?\w*)_from_vin$/
        true
      else
        respond_to_without_vin?(name)
      end
    end

    def model_from_vin(model_name, vin)
      model_name_new = model_name.split("_").inject("") do |sum, n|
        sum + n[0].upcase + n[1..-1]
      end

      code = vin[eval(model_name_new)::VIN_INDEX]
      model = eval(model_name_new).first(:vin_string => code)
      if model.nil?
        raise ModelNotFoundException, "No #{model_name} for the VIN."
      else
        model
      end
    end
  end
end
