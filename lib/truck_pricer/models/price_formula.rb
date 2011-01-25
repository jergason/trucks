module TruckPricer
  class PriceFormula
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :formula, String

    has 1, :truck_model
    has 1, :engine
    has 1, :year
  end
end
